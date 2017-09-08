//
//  WSChatListViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

class WSChatListViewModel: BaseChatGroupedListViewModel<ChatConversation>, ChatListViewModel {
    private var chatRepository: ChatRepository

    private(set) var chatsType: ChatsType
    private var selectedConversationIds: Set<String>
    weak var delegate: ChatListViewModelDelegate?

    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
    }

    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(chatsType: ChatsType,
                     tabNavigator: TabNavigator?) {
        self.init(chatRepository: Core.chatRepository, chats: [], chatsType: chatsType, tabNavigator: tabNavigator)
    }

    required init(chatRepository: ChatRepository,
                     chats: [ChatConversation],
                     chatsType: ChatsType,
                     tabNavigator: TabNavigator?) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        self.selectedConversationIds = Set<String>()
        
        let collectionVariable: CollectionVariable<ChatConversation>
        switch chatsType {
        case .all:
            collectionVariable = chatRepository.allConversations
        case .buying:
            collectionVariable = chatRepository.buyingConversations
        case .selling:
            collectionVariable = chatRepository.sellingConversations
        case .archived:
            collectionVariable = CollectionVariable<ChatConversation>([])
        }
        super.init(collectionVariable: collectionVariable,
                   shouldWriteInCollectionVariable: true,
                   tabNavigator: tabNavigator)
    }
    
    
    // MARK: - Public methods

    override func refresh(completion: (() -> Void)?) {
        retrievePage(firstPage, completion: completion)
    }
    
    override func index(_ page: Int, completion: ((Result<[ChatConversation], RepositoryError>) -> ())?) {
        let offset = max(0, page - 1) * resultsPerPage
        
        chatRepository.indexConversations(resultsPerPage, offset: offset, filter: chatsType.conversationFilter,
                                          completion: completion)
    }

    func isConversationSelected(index: Int) -> Bool {
        guard let conversation = objectAtIndex(index), let id = conversation.objectId else { return false }
        return selectedConversationIds.contains(id)
    }
    
    func selectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index), let id = conversation.objectId else { return }
        if editing {
            selectedConversationIds.insert(id)
        } else {
            tabNavigator?.openChat(.conversation(conversation: conversation), source: .chatList, predefinedMessage: nil)
        }
    }
    
    func deselectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index), let id = conversation.objectId else { return }
        if editing {
            selectedConversationIds.remove(id)
        }
    }
    
    func deselectAllConversations() {
        selectedConversationIds.removeAll()
    }
    
    func openConversation(index: Int) {
        guard let conversation = objectAtIndex(index) else { return }
        tabNavigator?.openChat(.conversation(conversation: conversation), source: .chatList, predefinedMessage: nil)
    }
    
    func conversationDataAtIndex(_ index: Int) -> ConversationCellData? {
        guard let conversation = objectAtIndex(index) else { return nil }
        return ConversationCellData(status: conversation.conversationCellStatus,
                                    userName: conversation.interlocutor?.name ?? "",
                                    userImageUrl: conversation.interlocutor?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(conversation.interlocutor?.objectId,
                                    name: conversation.interlocutor?.name),
                                    listingName: conversation.listing?.name ?? "",
                                    listingImageUrl: conversation.listing?.image?.fileURL,
                                    unreadCount: conversation.unreadMessageCount,
                                    messageDate: conversation.lastMessageSentAt)
    }


    // MARK: >  Unread

    var hasMessagesToRead: Bool {
        for index in 0..<objectCount {
            if (objectAtIndex(index)?.unreadMessageCount ?? 0) > 0 { return true }
        }
        return false
    }


    // MARK: > Send

    func deleteButtonPressed() {
        guard !selectedConversationIds.isEmpty else { return }

        let conversationIds = Array(selectedConversationIds)
        chatRepository.archiveConversations(conversationIds) { [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.error {
                strongSelf.delegate?.chatListViewModelDidFailArchivingChats(strongSelf)
            } else {
                strongSelf.delegate?.chatListViewModelDidSucceedArchivingChats(strongSelf)
            }
        }
    }

    func deleteConfirmationTitle(_ itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTitleOne :
            LGLocalizedString.chatListDeleteAlertTitleMultiple
    }

    func deleteConfirmationMessage(_ itemCount: Int) -> String {
        return itemCount <= 1 ? LGLocalizedString.chatListDeleteAlertTextOne :
            LGLocalizedString.chatListDeleteAlertTextMultiple
    }

    func deleteConfirmationCancelTitle() -> String {
        return LGLocalizedString.commonCancel
    }

    func deleteConfirmationSendButton() -> String {
        return LGLocalizedString.chatListDeleteAlertSend
    }
}


// MARK: - Extension helpers

fileprivate extension ChatsType {
    var conversationFilter: WebSocketConversationFilter {
        switch self {
        case .selling: return .asSeller
        case .buying: return .asBuyer
        case .archived: return .archived
        case .all: return .all
        }
    }
}

fileprivate extension ChatConversation {
    var conversationCellStatus: ConversationCellStatus {
        guard let listing = listing, let interlocutor = interlocutor else { return .userDeleted }
        if interlocutor.isBanned { return .forbidden }

        switch interlocutor.status {
        case .scammer:
            return .forbidden
        case .pendingDelete:
            return .userPendingDelete
        case .deleted:
            return .userDeleted
        case .active, .inactive, .notFound:
            break // In this case we rely on the product status
        }

        if interlocutor.isMuted {
            return .userBlocked
        }
        if interlocutor.hasMutedYou {
            return .blockedByUser
        }

        switch listing.status {
        case .deleted, .discarded:
            return .listingDeleted
        case .sold, .soldOld:
            return .listingSold
        case .approved, .pending:
            return .available
        }
    }
}
