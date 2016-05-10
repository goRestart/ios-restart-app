//
//  WSChatListViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class WSChatListViewModel: OldChatGroupedListViewModel<ChatConversation>, ChatListViewModel {
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

    required init(chatRepository: ChatRepository, chats: [ChatConversation], chatsType: ChatsType) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        super.init(objects: chats)
    }


    // MARK: - Public methods

    override func index(page: Int, completion: (Result<[ChatConversation], RepositoryError> -> ())?) {
        super.index(page, completion: completion)
        let offset = 0 //TODO: CALCULATE OFFSET!
        chatRepository.indexConversations(resultsPerPage, offset: offset, filter: chatsType.conversationFilter,
                                          completion: completion)
    }

    override func didFinishLoading() {
        super.didFinishLoading()

        if active {
            NotificationsManager.sharedInstance.updateCounters()
        }
    }

    func conversationDataAtIndex(index: Int) -> ConversationCellData? {
        guard let conversation = objectAtIndex(index) else { return nil }

        return ConversationCellData(status: conversation.conversationCellStatus,
                                    userName: conversation.interlocutor?.name ?? "",
                                    userImageUrl: conversation.interlocutor?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                        name: conversation.interlocutor?.name),
                                    productName: conversation.product?.name ?? "",
                                    productImageUrl: conversation.product?.image?.fileURL,
                                    unreadCount: conversation.unreadMessageCount,
                                    messageDate: conversation.lastMessageSentAt)
    }

    func oldChatViewModelForIndex(index: Int) -> OldChatViewModel? {
        return nil
    }

    func chatViewModelForIndex(index: Int) -> ChatViewModel? {
        guard let conversation = objectAtIndex(index) else { return nil }
        return ChatViewModel(conversation: conversation)
    }


    // MARK: >  Unread

    var hasMessagesToRead: Bool {
        for index in 0..<objectCount {
            if objectAtIndex(index)?.unreadMessageCount > 0 { return true }
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
        let conversationIds: [String] = indexes.filter { $0 < objectCount && $0 >= 0 }.flatMap {
            objectAtIndex($0)?.objectId
        }
        chatRepository.archiveConversations(conversationIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailArchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedArchivingChats(strongSelf)
            }
        }
    }
}

private extension ChatsType {
    var conversationFilter: WebSocketConversationFilter {
        switch self {
        case .Selling: return .AsSeller
        case .Buying: return .asBuyer
        case .Archived: return .Archived
        case .All: return .None
        }
    }
}

private extension ChatConversation {
    var conversationCellStatus: ConversationCellStatus {
        guard let product = product, interlocutor = interlocutor else { return .Deleted }
        if interlocutor.isBlocked { return .Forbidden }
        switch product.status {
        case .Deleted, .Discarded:
            return .Deleted
        case .Sold, .SoldOld:
            return .Sold
        case .Approved, .Pending:
            return .Available
        }
    }
}
