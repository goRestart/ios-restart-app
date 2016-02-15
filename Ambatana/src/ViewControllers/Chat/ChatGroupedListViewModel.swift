//
//  ChatGroupedListViewModel.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

protocol ChatGroupedListViewModelType: Paginable {
    func reloadCurrentPagesWithCompletion(completion: (() -> ())?)
    func setEditing(editing: Bool, animated: Bool)
}

protocol ChatGroupedListViewModelDelegate: class {
    func chatGroupedListViewModelShouldUpdateStatus()

    func chatGroupedListViewModelSetEditing(editing: Bool, animated: Bool)

    func chatGroupedListViewModelDidStartRetrievingObjectList()
    func chatGroupedListViewModelDidFailRetrievingObjectList(page: Int)
    func chatGroupedListViewModelDidSucceedRetrievingObjectList(page: Int)
}

class ChatGroupedListViewModel<T>: BaseViewModel, ChatGroupedListViewModelType {

    private var objects: [T] = []

    private(set) var status: ChatListStatus

    var emptyIcon: UIImage?
    var emptyTitle: String?
    var emptyBody: String?
    var emptyButtonTitle: String?
    var emptyAction: (() -> ())?

    weak var chatGroupedDelegate : ChatGroupedListViewModelDelegate?


    // MARK: - Paginable

    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return objects.count
    }


    // MARK: - Lifecycle

    required init(objects: [T]) {
        self.objects = objects
        self.status = .LoadingConversations
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active && canRetrieve {
            if objects.isEmpty {
                retrieveFirstPage()
            } else {
                reloadCurrentPagesWithCompletion(nil)
            }
        }
    }


    // MARK: - Public methods
    // MARK: > Chats

    func objectAtIndex(index: Int) -> T? {
        guard index < objects.count else { return nil }
        return objects[index]
    }

    func clear() {
        objects = []
        nextPage = 1
        isLastPage = false
        isLoading = false
    }

    func index(page: Int, completion: (Result<[T], RepositoryError> -> ())?) {
        // Must be implemented in subclasses
    }




    var activityIndicatorAnimating: Bool {
        switch status {
        case .NoConversations, .Error, .Conversations:
            return false
        case .LoadingConversations:
            return true
        }
    }

    var emptyViewHidden: Bool {
        switch status {
        case .NoConversations, .Error:
            return false
        case .LoadingConversations, .Conversations:
            return true
        }
    }

    var emptyViewModel: LGEmptyViewModel? {
        switch status {
        case let .NoConversations(viewModel):
            return viewModel
        case let .Error(viewModel):
            return viewModel
        case .LoadingConversations, .Conversations:
            return nil
        }
    }

    var tableViewHidden: Bool {
        switch status {
        case .NoConversations, .Error, .LoadingConversations:
            return true
        case .Conversations:
            return false
        }
    }


    // MARK: > Unread message count

    func updateUnreadMessagesCount() {
        // TODO: 🔴!!!
//        PushManager.sharedInstance.updateUnreadMessagesCount()
    }


    // MARK: - ChatGroupedListViewModelType


    func reloadCurrentPagesWithCompletion(completion: (() -> ())?) {
        guard firstPage < nextPage else {
            completion?()
            return
        }

        isLoading = true
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()

        var reloadedObjects: [T] = []
        let chatReloadQueue = dispatch_queue_create("ChatGroupedReloadQueue", DISPATCH_QUEUE_SERIAL)

        // Request object pages serially
        var queueError: RepositoryError?
        dispatch_async(chatReloadQueue, { [weak self] in
            guard let strongSelf = self else { return }

            for page in strongSelf.firstPage..<strongSelf.nextPage {
                let result = synchronize({ completion in
                    self?.index(page, completion: { (result: Result<[T], RepositoryError>) -> () in
                        completion(result)
                    })
                    }, timeoutWith: Result<[T], RepositoryError>(error: RepositoryError.Network))

                if let value = result.value {
                    reloadedObjects += value
                } else if let error = result.error {
                    // If an error is found do not request next pages
                    queueError = error
                    break
                }
            }

            strongSelf.isLoading = false

            dispatch_async(dispatch_get_main_queue()) {
                // Status update
                if let error = queueError {
                    let emptyVM = strongSelf.emptyViewModelForError(error)
                    strongSelf.status = .Error(emptyVM)
                } else if reloadedObjects.isEmpty {
                    let emptyVM = strongSelf.buildEmptyViewModel()
                    strongSelf.status = .NoConversations(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }

                // Data update (if success) & delegate notification
                if let _ = queueError {
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(strongSelf.nextPage)
                } else {
                    strongSelf.objects = reloadedObjects
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(strongSelf.nextPage)
                }

                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()

                // TODO: 🔴!!!
                //                strongSelf.updateUnreadMessagesCount()

                completion?()
            }
            })
    }
    
    func setEditing(editing: Bool, animated: Bool) {
        chatGroupedDelegate?.chatGroupedListViewModelSetEditing(editing, animated: animated)
    }


    // MARK: - Paginable

    func retrievePage(page: Int) {
        let firstPage = (page == 1)
        isLoading = true
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()

        index(page) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {

                if firstPage {
                    strongSelf.objects = value
                } else {
                    strongSelf.objects += value
                }

                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1

                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.buildEmptyViewModel()
                    strongSelf.status = .NoConversations(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(page)
            } else if let error = result.error {
                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.emptyViewModelForError(error)
                    strongSelf.status = .Error(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(page)
            }
            strongSelf.isLoading = false
        }

        // TODO: 🔴!!!
//        updateUnreadMessagesCount()
    }


    // MARK: - Private methods

    private func emptyViewModelForError(error: RepositoryError) -> LGEmptyViewModel {
        let retryAction: () -> () = { [weak self] in
            self?.retrieveFirstPage()
        }
        let emptyVM: LGEmptyViewModel
        switch error {
        case .Network:
            emptyVM = LGEmptyViewModel.networkErrorWithRetry(retryAction)
        case .Internal, .NotFound, .Unauthorized:
            emptyVM = LGEmptyViewModel.genericErrorWithRetry(retryAction)
        }
        return emptyVM
    }
    
    private func buildEmptyViewModel() -> LGEmptyViewModel {
        return LGEmptyViewModel(icon: emptyIcon, title: emptyTitle, body: emptyBody, buttonTitle: emptyButtonTitle,
            action: emptyAction)
    }

}
