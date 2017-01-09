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
    weak var delegate: ChatListViewModelDelegate?

    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
    }

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    convenience init(chatsType: ChatsType, tabNavigator: TabNavigator?) {
        self.init(chatRepository: Core.chatRepository, chats: [], chatsType: chatsType, tabNavigator: tabNavigator)
    }

    required init(chatRepository: ChatRepository, chats: [ChatConversation], chatsType: ChatsType,
                  tabNavigator: TabNavigator?) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        super.init(objects: chats, tabNavigator: tabNavigator)
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    required init(objects: [T], tabNavigator: TabNavigator?) {
        fatalError("init(objects:tabNavigator:) has not been implemented")
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            setupRxBindings()
        }
    }

    // MARK: - Public methods

    override func index(_ page: Int, completion: ((Result<[ChatConversation], RepositoryError>) -> ())?) {
        let offset = max(0, page - 1) * resultsPerPage
        
        chatRepository.indexConversations(resultsPerPage, offset: offset, filter: chatsType.conversationFilter,
                                          completion: completion)
    }

    override func didFinishLoading() {
        super.didFinishLoading()

        if active {
            NotificationsManager.sharedInstance.updateChatCounters()
        }
    }

    func conversationSelectedAtIndex(_ index: Int) {
        guard let conversation = objectAtIndex(index) else { return }
        tabNavigator?.openChat(.conversation(conversation: conversation))
    }

    func conversationDataAtIndex(_ index: Int) -> ConversationCellData? {
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

    func deleteChatsAtIndexes(_ indexes: [Int]) {
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


    // MARK: - Private methods

    fileprivate func setupRxBindings() {
        chatRepository.chatEvents.filter { event in
            switch event.type {
            case .interlocutorMessageSent:
                return true
            default:
                return false
            }
        }.bindNext { [weak self] event in
            self?.reloadCurrentPagesWithCompletion(nil)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - Extension helpers

fileprivate extension ChatsType {
    var conversationFilter: WebSocketConversationFilter {
        switch self {
        case .selling: return .AsSeller
        case .Buying: return .asBuyer
        case .Archived: return .Archived
        case .All: return .None
        }
    }
}

fileprivate extension ChatConversation {
    var conversationCellStatus: ConversationCellStatus {
        guard let product = product, let interlocutor = interlocutor else { return .userDeleted }
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

        switch product.status {
        case .deleted, .discarded:
            return .productDeleted
        case .sold, .soldOld:
            return .productSold
        case .approved, .pending:
            return .available
        }
    }
}
