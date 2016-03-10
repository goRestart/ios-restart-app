//
//  ChatGroupedListViewModel.swift
//  LetGo
//
//  Created by Dídac on 15/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

/**
Defines the type shared across 'Chats' section lists.
*/
protocol ChatGroupedListViewModelType: RxPaginable {
    var editing: Variable<Bool> { get }
    func reloadCurrentPagesWithCompletion(completion: (() -> ())?)
}

protocol ChatGroupedListViewModelDelegate: class {
    func chatGroupedListViewModelShouldUpdateStatus()
    func chatGroupedListViewModelSetEditing(editing: Bool)
    func chatGroupedListViewModelDidStartRetrievingObjectList()
    func chatGroupedListViewModelDidFailRetrievingObjectList(page: Int)
    func chatGroupedListViewModelDidSucceedRetrievingObjectList(page: Int)
}

enum ChatGroupedListStatus {
    case Loading
    case Data
    case Empty(LGEmptyViewModel)
    case Error(LGEmptyViewModel)
}

class ChatGroupedListViewModel<T>: BaseViewModel, ChatGroupedListViewModelType {

    private let objects: Variable<[T]>

    private(set) var status: ChatGroupedListStatus

    var emptyIcon: UIImage?
    var emptyTitle: String?
    var emptyBody: String?
    var emptyButtonTitle: String?
    var emptyAction: (() -> ())?
    var emptySecondaryButtonTitle: String?
    var emptySecondaryAction: (() -> ())?

    weak var chatGroupedDelegate : ChatGroupedListViewModelDelegate?


    // MARK: - Paginable

    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return objects.value.count
    }
    let rx_objectCount = Variable<Int>(0)
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    required init(objects: [T]) {
        self.objects = Variable<[T]>(objects)
        self.status = .Loading
        super.init()

        setupPaginableRxBindings()
    }

    override func didSetActive(active: Bool) {
        if active && canRetrieve {
            if objectCount == 0 {
                retrieveFirstPage()
            } else {
                reloadCurrentPagesWithCompletion(nil)
            }
        }
    }


    // MARK: - Public methods

    func objectAtIndex(index: Int) -> T? {
        guard index < objectCount else { return nil }
        return objects.value[index]
    }

    func clear() {
        objects.value = []
        nextPage = 1
        isLastPage = false
        isLoading = false
    }

    func selectedObjectsAtIndexes(indexes: [Int]) -> [T]? {
        return indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap { objects.value[$0] }
    }

    func index(page: Int, completion: (Result<[T], RepositoryError> -> ())?) {
        // Must be implemented in subclasses
    }

    func didFinishLoading() {
        // Must be implemented in subclasses
    }

    var activityIndicatorAnimating: Bool {
        switch status {
        case .Empty, .Error, .Data:
            return false
        case .Loading:
            return true
        }
    }

    var emptyViewHidden: Bool {
        switch status {
        case .Empty, .Error:
            return false
        case .Loading, .Data:
            return true
        }
    }

    var emptyViewModel: LGEmptyViewModel? {
        switch status {
        case let .Empty(viewModel):
            return viewModel
        case let .Error(viewModel):
            return viewModel
        case .Loading, .Data:
            return nil
        }
    }

    var tableViewHidden: Bool {
        switch status {
        case .Empty, .Error, .Loading:
            return true
        case .Data:
            return false
        }
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
                    strongSelf.status = .Empty(emptyVM)
                } else {
                    strongSelf.status = .Data
                }

                // Data update (if success) & delegate notification
                if let _ = queueError {
                    strongSelf.objects.value = []
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(strongSelf.nextPage)
                } else {
                    strongSelf.objects.value = reloadedObjects
                    strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(strongSelf.nextPage)
                }

                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.didFinishLoading()

                completion?()
            }
        })
    }

    let editing = Variable<Bool>(false)


    // MARK: - Paginable

    func retrievePage(page: Int) {
        let firstPage = (page == 1)
        isLoading = true
        chatGroupedDelegate?.chatGroupedListViewModelDidStartRetrievingObjectList()

        index(page) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {

                if firstPage {
                    strongSelf.objects.value = value
                } else {
                    strongSelf.objects.value = strongSelf.objects.value + value
                }

                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1

                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.buildEmptyViewModel()
                    strongSelf.status = .Empty(emptyVM)
                } else {
                    strongSelf.status = .Data
                }
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidSucceedRetrievingObjectList(page)
            } else if let error = result.error {
                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.emptyViewModelForError(error)
                    strongSelf.status = .Error(emptyVM)
                } else {
                    strongSelf.status = .Data
                }
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelShouldUpdateStatus()
                strongSelf.chatGroupedDelegate?.chatGroupedListViewModelDidFailRetrievingObjectList(page)
            }
            strongSelf.isLoading = false
        }

        didFinishLoading()
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
            action: emptyAction,  secondaryButtonTitle: emptySecondaryButtonTitle, secondaryAction: emptySecondaryAction)
    }
}


// MARK: - Rx

extension ChatGroupedListViewModel {
    private func setupPaginableRxBindings() {
        objects.asObservable().map { messages in
            return messages.count
        }.bindTo(rx_objectCount).addDisposableTo(disposeBag)

        editing.asObservable().subscribeNext { [weak self] editing in
            self?.chatGroupedDelegate?.chatGroupedListViewModelSetEditing(editing)
        }.addDisposableTo(disposeBag)
    }
}
