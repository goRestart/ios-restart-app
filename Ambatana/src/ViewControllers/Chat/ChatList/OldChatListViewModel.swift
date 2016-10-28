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

    private(set) var chatsType: ChatsType
    weak var delegate: ChatListViewModelDelegate?
    
    var titleForDeleteButton: String {
        return LGLocalizedString.chatListDelete
    }

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(chatsType: ChatsType, tabNavigator: TabNavigator?) {
        self.init(chatRepository: Core.oldChatRepository, chats: [], chatsType: chatsType, tabNavigator: tabNavigator)
    }

    required init(chatRepository: OldChatRepository, chats: [Chat], chatsType: ChatsType, tabNavigator: TabNavigator?) {
        self.chatRepository = chatRepository
        self.chatsType = chatsType
        super.init(objects: chats, tabNavigator: tabNavigator)
    }


    // MARK: - Public methods

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            setupRxBindings()
        }
    }

    override func index(page: Int, completion: (Result<[Chat], RepositoryError> -> ())?) {
        super.index(page, completion: completion)
        chatRepository.index(chatsType, page: page, numResults: resultsPerPage, completion: completion)
    }

    override func didFinishLoading() {
        super.didFinishLoading()

        if active {
            NotificationsManager.sharedInstance.updateChatCounters()
        }
    }

    func conversationSelectedAtIndex(index: Int) {
        guard let chat = objectAtIndex(index) else { return }
        tabNavigator?.openChat(.ChatAPI(chat: chat))
    }

    func conversationDataAtIndex(index: Int) -> ConversationCellData? {
        guard let chat = objectAtIndex(index) else { return nil }
        guard let myUser = Core.myUserRepository.myUser else { return nil }

        var otherUser: User?
        if let myUserId = myUser.objectId, let userFromId = chat.userFrom.objectId, let _ = chat.userTo.objectId {
            otherUser = (myUserId == userFromId) ? chat.userTo : chat.userFrom
        }

        return ConversationCellData(status: chat.conversationCellStatus(otherUser),
                                    userName: otherUser?.name ?? "",
                                    userImageUrl: otherUser?.avatar?.fileURL,
                                    userImagePlaceholder: LetgoAvatar.avatarWithID(otherUser?.objectId, name: otherUser?.name),
                                    productName: chat.product.title ?? "",
                                    productImageUrl: chat.product.thumbnail?.fileURL,
                                    unreadCount: chat.msgUnreadCount,
                                    messageDate: chat.updatedAt)
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

    private func setupRxBindings() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext{ [weak self] _ in
            self?.reloadCurrentPagesWithCompletion(nil)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: Extension helpers

private extension Chat {
    func conversationCellStatus(otherUser: User?) -> ConversationCellStatus {
        if let otherUser = otherUser {
            switch otherUser.status {
            case .Scammer:
                return .Forbidden
            case .PendingDelete:
                return .UserPendingDelete
            case .Deleted:
                return .UserDeleted
            case .Active, .Inactive, .NotFound:
                break // In this case we rely on the chat status
            }
        }

        switch self.status {
        case .Forbidden:
            return .Forbidden
        case .Sold:
            return .ProductSold
        case .Deleted:
            return .ProductDeleted
        case .Available:
            return .Available
        }
    }
}
