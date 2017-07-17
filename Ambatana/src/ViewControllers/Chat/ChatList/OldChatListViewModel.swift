//
//  OldChatListViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import RxSwift

class OldChatListViewModel: BaseChatGroupedListViewModel<Chat>, ChatListViewModel {
    private var chatRepository: OldChatRepository
    private var deepLinksRouter: DeepLinksRouter

    private(set) var chatsType: ChatsType
    private var selectedConversationIds: Set<String>
    weak var delegate: ChatListViewModelDelegate?
    
    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
    }

    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(chatsType: ChatsType, tabNavigator: TabNavigator?) {
        self.init(chatRepository: Core.oldChatRepository,
                  deepLinksRouter: LGDeepLinksRouter.sharedInstance,
                  chats: [],
                  chatsType: chatsType,
                  tabNavigator: tabNavigator)
    }

    required init(chatRepository: OldChatRepository,
                  deepLinksRouter: DeepLinksRouter,
                  chats: [Chat],
                  chatsType: ChatsType,
                  tabNavigator: TabNavigator?) {
        self.chatRepository = chatRepository
        self.deepLinksRouter = deepLinksRouter
        self.chatsType = chatsType
        self.selectedConversationIds = Set<String>()
        super.init(collectionVariable: CollectionVariable(chats),
                   shouldWriteInCollectionVariable: false,
                   tabNavigator: tabNavigator)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        refresh(completion: nil)
        if firstTime {
            setupRxBindings()
        }
    }
    
    
    // MARK: - Public methods

    override func index(_ page: Int, completion: ((Result<[Chat], RepositoryError>) -> ())?) {
        super.index(page, completion: completion)
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage, completion: completion)
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
            tabNavigator?.openChat(.chatAPI(chat: conversation), source: .chatList, predefinedMessage: nil)
        }
    }
    
    func deselectConversation(index: Int, editing: Bool) {
        guard let conversation = objectAtIndex(index), let id = conversation.objectId else { return }
        if editing {
            selectedConversationIds.remove(id)
        } else {
            tabNavigator?.openChat(.chatAPI(chat: conversation), source: .chatList, predefinedMessage: nil)
        }
    }

    func deselectAllConversations() {
        selectedConversationIds.removeAll()
    }
    
    func openConversation(index: Int) {
        guard let chat = objectAtIndex(index) else { return }
        tabNavigator?.openChat(.chatAPI(chat: chat), source: .chatList, predefinedMessage: nil)
    }

    func conversationDataAtIndex(_ index: Int) -> ConversationCellData? {
        guard let chat = objectAtIndex(index) else { return nil }
        guard let myUser = Core.myUserRepository.myUser else { return nil }

        var otherUser: User?
        if let myUserId = myUser.objectId, let userFromId = chat.userFrom.objectId, let _ = chat.userTo.objectId {
            otherUser = (myUserId == userFromId) ? LocalUser(userListing: chat.userTo) : LocalUser(userListing: chat.userFrom)
        }

        return ConversationCellData(status: chat.conversationCellStatus(otherUser),
                                    userName: otherUser?.name ?? "",
                                    userImageUrl: otherUser?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(otherUser?.objectId, name: otherUser?.name),
                                    productName: chat.listing.title ?? "",
                                    productImageUrl: chat.listing.thumbnail?.fileURL,
                                    unreadCount: chat.msgUnreadCount,
                                    messageDate: chat.updatedAt)
    }


    // MARK: >  Unread

    var hasMessagesToRead: Bool {
        for index in 0..<objectCount {
            if let object = objectAtIndex(index), object.msgUnreadCount > 0 { return true }
        }
        return false
    }


    // MARK: > Send

    func deleteButtonPressed() {
        guard !selectedConversationIds.isEmpty else { return }
        
        let chatIds = Array(selectedConversationIds)
        chatRepository.archiveChatsWithIds(chatIds) { [weak self] result in
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


    // MARK: - Private methods

    private func setupRxBindings() {
        deepLinksRouter.chatDeepLinks.subscribeNext{ [weak self] _ in
            self?.refresh(completion: nil)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: Extension helpers

fileprivate extension Chat {
    func conversationCellStatus(_ otherUser: User?) -> ConversationCellStatus {
        if let otherUser = otherUser {
            switch otherUser.status {
            case .scammer:
                return .forbidden
            case .pendingDelete:
                return .userPendingDelete
            case .deleted:
                return .userDeleted
            case .active, .inactive, .notFound:
                break // In this case we rely on the chat status
            }
        }

        switch self.status {
        case .forbidden:
            return .forbidden
        case .sold:
            return .productSold
        case .deleted:
            return .productDeleted
        case .available:
            return .available
        }
    }
}
