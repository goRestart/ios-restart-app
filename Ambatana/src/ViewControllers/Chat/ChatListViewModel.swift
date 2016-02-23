//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result


protocol ChatListViewModelDelegate: class {
    func chatListViewModelShouldUpdateStatus(viewModel: ChatListViewModel)
    func chatListViewModel(viewModel: ChatListViewModel, setEditing editing: Bool, animated: Bool)
    func chatListViewModelDidStartRetrievingChatList(viewModel: ChatListViewModel)
    func chatListViewModelDidFailRetrievingChatList(viewModel: ChatListViewModel, page: Int)
    func chatListViewModelDidSucceedRetrievingChatList(viewModel: ChatListViewModel, page: Int)

    func vmArchiveSelectedChats()
    func vmUnarchiveSelectedChats()
    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(viewModel: ChatListViewModel)
}

class ChatListViewModel : ChatGroupedListViewModel<Chat> {
    private var chatRepository: ChatRepository

    private(set) var chatsType: ChatsType
    weak var delegate: ChatListViewModelDelegate?
    private(set) var status: ChatListStatus

    var emptyIcon: UIImage?
    var emptyTitle: String?
    var emptyBody: String?
    var emptyButtonTitle: String?
    var emptyAction: (() -> ())?


    // MARK: - Paginable
    
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    
    var objectCount: Int {
        return chats.count
    }

    var titleForArchiveButton: String {
        return chatsType == .Archived ? LGLocalizedString.chatListUnarchive : LGLocalizedString.chatListArchive
    }


    // MARK: - Lifecycle
    
    convenience init(chatsType: ChatsType) {
        self.init(chatRepository: Core.chatRepository, chats: [], chatsType: chatsType)
    }

    required init(chatRepository: ChatRepository, chats: [Chat], chatsType: ChatsType) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        super.init(objects: chats)
    }


    // MARK: - Public methods

    override func index(page: Int, completion: (Result<[Chat], RepositoryError> -> ())?) {
        super.index(page, completion: completion)
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage, completion: completion)
    }

    override func didFinishLoading() {
        super.didFinishLoading()

        if active {
            PushManager.sharedInstance.updateUnreadMessagesCount()
        }
    }


    // MARK: > Archive

    func archiveButtonPressed() {
        if chatsType == .Archived {
            delegate?.vmUnarchiveSelectedChats()
        } else {
            delegate?.vmArchiveSelectedChats()
        }
    }

    let archiveConfirmationTitle = LGLocalizedString.chatListArchiveAlertTitle
    let archiveConfirmationMessage = LGLocalizedString.chatListArchiveAlertText
    let archiveConfirmationCancelTitle = LGLocalizedString.commonCancel
    let archiveConfirmationArchiveTitle = LGLocalizedString.chatListArchive

    func archiveChatsAtIndexes(indexes: [Int]) {
        let chatIds: [String] = indexes.filter{$0 < chats.count && $0 >= 0}.flatMap{chats[$0].objectId}

        chatRepository.archiveChatsWithIds(chatIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailArchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedArchivingChats(strongSelf)
            }
        }
    }

    func unarchiveChatsAtIndexes(indexes: [Int]) {
        let chatIds: [String] = indexes.filter{$0 < chats.count && $0 >= 0}.flatMap{chats[$0].objectId}

        chatRepository.unarchiveChatsWithIds(chatIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailUnarchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedUnarchivingChats(strongSelf)
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
