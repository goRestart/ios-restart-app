//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

enum ChatListStatus {
    case LoadingConversations
    case Conversations
    case NoConversations(LGEmptyViewModel)
    case Error(LGEmptyViewModel)
}

protocol ChatListViewModelDelegate: class {
    func chatListViewModelShouldUpdateStatus(viewModel: ChatListViewModel)

    func chatListViewModel(viewModel: ChatListViewModel, setEditing editing: Bool, animated: Bool)

    func chatListViewModelDidStartRetrievingChatList(viewModel: ChatListViewModel)
    func chatListViewModelDidFailRetrievingChatList(viewModel: ChatListViewModel, page: Int)
    func chatListViewModelDidSucceedRetrievingChatList(viewModel: ChatListViewModel, page: Int)
    
    func chatListViewModelDidFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
    func chatListViewModelDidSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
}

class ChatListViewModel : BaseViewModel, Paginable {
    private var chats: [Chat] = []
    private var chatRepository: ChatRepository

    private(set) var archivedChats = 0
    private(set) var failedArchivedChats = 0
    private(set) var chatsType: ChatsType

    private(set) var status: ChatListStatus

    var emptyIcon: UIImage?
    var emptyTitle: String?
    var emptyBody: String?
    var emptyButtonTitle: String?
    var emptyAction: (() -> ())?

    weak var delegate : ChatListViewModelDelegate?


    // MARK: - Paginable
    
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    
    var objectCount: Int {
        return chats.count
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(tab: ChatGroupedViewModel.Tab) {
        self.init(chatRepository: Core.chatRepository, chats: [], tab: tab)
    }

    required init(chatRepository: ChatRepository, chats: [Chat], tab: ChatGroupedViewModel.Tab) {
        self.chatRepository = chatRepository
        self.chats = chats
        self.chatsType = tab.chatsType
        self.status = .LoadingConversations
        super.init()
    }

    override func didSetActive(active: Bool) {
        if active && canRetrieve {
            if chats.isEmpty {
                retrieveFirstPage()
            } else {
                reloadCurrentPagesWithCompletion(nil)
            }
        }
    }


    // MARK: - Public methods
    // MARK: > Chats

    func chatAtIndex(index: Int) -> Chat? {
        guard index < chats.count else { return nil }
        return chats[index]
    }

    func clearChatList() {
        chats = []
        nextPage = 1
        isLastPage = false
        isLoading = false
    }

    func reloadCurrentPagesWithCompletion(completion: (() -> ())?) {
        guard firstPage < nextPage else {
            completion?()
            return
        }

        isLoading = true
        delegate?.chatListViewModelDidStartRetrievingChatList(self)

        var reloadedChats: [Chat] = []
        let chatReloadQueue = dispatch_queue_create("ChatReloadQueue", DISPATCH_QUEUE_SERIAL)

        // Request chat pages serially
        let chatsType = self.chatsType
        let resultsPerPage = self.resultsPerPage
        var queueError: RepositoryError?
        dispatch_async(chatReloadQueue, { [weak self] in
            guard let strongSelf = self else { return }

            for page in strongSelf.firstPage..<strongSelf.nextPage {
                let result = synchronize({ completion in
                    self?.chatRepository.index(chatsType, page: page, numResults: resultsPerPage) { result in
                        completion(result)
                    }
                }, timeoutWith: ChatsResult(error: RepositoryError.Network))
                
                if let value = result.value {
                    reloadedChats += value
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
                    strongSelf.delegate?.chatListViewModelShouldUpdateStatus(strongSelf)
                } else if reloadedChats.isEmpty {
                    let emptyVM = strongSelf.buildEmptyViewModel()
                    strongSelf.status = .NoConversations(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }

                // Data update (if success) & delegate notification
                if let _ = queueError {
                    strongSelf.delegate?.chatListViewModelDidFailRetrievingChatList(strongSelf,
                        page: strongSelf.nextPage)
                } else {
                    strongSelf.chats = reloadedChats
                    strongSelf.delegate?.chatListViewModelDidSucceedRetrievingChatList(strongSelf,
                        page: strongSelf.nextPage)
                }

                strongSelf.delegate?.chatListViewModelShouldUpdateStatus(strongSelf)
                strongSelf.updateUnreadMessagesCount()

                completion?()
            }
        })
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
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }


    // MARK: > Edit

    func setEditing(editing: Bool, animated: Bool) {
        delegate?.chatListViewModel(self, setEditing: editing, animated: animated)
    }


    // MARK: > Archive

    let archiveConfirmationTitle = LGLocalizedString.chatListArchiveAlertTitle
    let archiveConfirmationMessage = LGLocalizedString.chatListArchiveAlertText
    let archiveConfirmationCancelTitle = LGLocalizedString.commonCancel
    let archiveConfirmationArchiveTitle = LGLocalizedString.chatListArchive

    func archiveChatsAtIndexes(indexes: [Int]) {
        archivedChats = 0
        failedArchivedChats = 0
        for index in indexes {
            guard index < chats.count else { continue }

            guard let chatId = chats[index].objectId else { continue }
            chatRepository.archiveChatsWithIds([chatId]) { [weak self] result in

                guard let strongSelf = self else { return }
                strongSelf.archivedChats++
                if let _ = result.error {
                    strongSelf.failedArchivedChats++
                    strongSelf.delegate?.chatListViewModelDidFailArchivingChat(strongSelf, atPosition: index,
                        ofTotal: indexes.count)
                } else {
                    strongSelf.delegate?.chatListViewModelDidSucceedArchivingChat(strongSelf, atPosition: index,
                        ofTotal: indexes.count)
                }
            }
        }
    }

    
    // MARK: - Paginable

    func retrievePage(page: Int) {
        let firstPage = (page == 1)
        isLoading = true
        delegate?.chatListViewModelDidStartRetrievingChatList(self)

        chatRepository.index(chatsType, page: page, numResults: resultsPerPage) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {

                if firstPage {
                    strongSelf.chats = value
                } else {
                    strongSelf.chats += value
                }
                
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1

                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.buildEmptyViewModel()
                    strongSelf.status = .NoConversations(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }
                strongSelf.delegate?.chatListViewModelShouldUpdateStatus(strongSelf)
                strongSelf.delegate?.chatListViewModelDidSucceedRetrievingChatList(strongSelf, page: page)
            } else if let error = result.error {
                if firstPage && strongSelf.objectCount == 0 {
                    let emptyVM = strongSelf.emptyViewModelForError(error)
                    strongSelf.status = .Error(emptyVM)
                } else {
                    strongSelf.status = .Conversations
                }

                strongSelf.delegate?.chatListViewModelShouldUpdateStatus(strongSelf)
                strongSelf.delegate?.chatListViewModelDidFailRetrievingChatList(strongSelf, page: page)
            }
            strongSelf.isLoading = false
        }
        
        updateUnreadMessagesCount()
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
