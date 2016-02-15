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
    func chatListViewModelDidFailArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
    func chatListViewModelDidSucceedArchivingChat(viewModel: ChatListViewModel, atPosition: Int, ofTotal: Int)
}

class ChatListViewModel : ChatGroupedListViewModel<Chat> {
    private var chatRepository: ChatRepository

    private(set) var archivedChats = 0
    private(set) var failedArchivedChats = 0
    private(set) var chatsType: ChatsType

    weak var chatListViewModelDelegate : ChatListViewModelDelegate?


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
    // MARK: > Chats

    override func index(page: Int, completion: (Result<[Chat], RepositoryError> -> ())?) {
        super.index(page, completion: completion)
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage, completion: completion)
    }


    // MARK: > Unread message count
    // TODO: 🔴!!!
//    func updateUnreadMessagesCount() {
//        PushManager.sharedInstance.updateUnreadMessagesCount()
//    }


    // MARK: > Archive

    let archiveConfirmationTitle = LGLocalizedString.chatListArchiveAlertTitle
    let archiveConfirmationMessage = LGLocalizedString.chatListArchiveAlertText
    let archiveConfirmationCancelTitle = LGLocalizedString.commonCancel
    let archiveConfirmationArchiveTitle = LGLocalizedString.chatListArchive

    func archiveChatsAtIndexes(indexes: [Int]) {
        archivedChats = 0
        failedArchivedChats = 0
        for index in indexes {
            guard let chat = objectAtIndex(index) else { continue }

            chatRepository.archiveChatWithId(chat) { [weak self] result in
                guard let strongSelf = self else { return }

                strongSelf.archivedChats++
                if let _ = result.error {
                    strongSelf.failedArchivedChats++
                    strongSelf.chatListViewModelDelegate?.chatListViewModelDidFailArchivingChat(strongSelf,
                        atPosition: index, ofTotal: indexes.count)
                } else {
                    strongSelf.chatListViewModelDelegate?.chatListViewModelDidSucceedArchivingChat(strongSelf,
                        atPosition: index, ofTotal: indexes.count)
                }
            }
        }
    }
}
