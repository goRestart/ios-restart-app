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
    func vmDeleteSelectedChats()
    func chatListViewModelDidFailArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedArchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidFailUnarchivingChats(viewModel: ChatListViewModel)
    func chatListViewModelDidSucceedUnarchivingChats(viewModel: ChatListViewModel)
}


class ChatListViewModel : ChatGroupedListViewModel<Chat> {
    private var chatRepository: ChatRepository

    private(set) var chatsType: ChatsType
    weak var delegate: ChatListViewModelDelegate?
    

    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
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


    // MARK: >  Unread

    var hasMessagesToRead: Bool {
        for index in 0..<objectCount {
            if objectAtIndex(index)?.msgUnreadCount > 0 { return true }
        }
        return false
    }


    // MARK: > Send

    func deleteButtonPressed() {
        delegate?.vmDeleteSelectedChats()
    }

    func deleteConfirmationTitle(itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTitleOne :
            LGLocalizedString.chatListDeleteAlertTitleMultiple
    }

    func deleteConfirmationMessage(itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTextOne :
            LGLocalizedString.chatListDeleteAlertTextMultiple
    }

    func deleteConfirmationCancelTitle() -> String {
        return LGLocalizedString.commonCancel
    }

    func deleteConfirmationSendButton() -> String {
        return LGLocalizedString.chatListDeleteAlertSend
    }

    func deleteChatsAtIndexes(indexes: [Int]) {
        let chatIds: [String] = indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap {
            objectAtIndex($0)?.objectId
        }

        chatRepository.archiveChatsWithIds(chatIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailArchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedArchivingChats(strongSelf)
            }
        }
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
