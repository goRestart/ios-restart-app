//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

public protocol ChatListViewModelDelegate: class {
    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool)
    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ChatsRetrieveServiceError)
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool)
}

public class ChatListViewModel : BaseViewModel {

    public weak var delegate : ChatListViewModelDelegate?

    public var chats: [Chat]?
    var chatManager: ChatManager

    // computed iVars
    public var chatCount : Int {
        return chats?.count ?? 0
    }

    // MARK: - Lifecycle

    public override convenience init() {
        self.init(chatManager: ChatManager.sharedInstance, chats: [])
    }

    public required init(chatManager: ChatManager, chats: [Chat]) {
        self.chatManager = chatManager
        self.chats = chats
        super.init()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didSetActive(active: Bool) {
        if active {
            // NSNotificationCenter, observe for user interactions (msgs & offers)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConversations",
                name: PushManager.Notification.DidReceiveUserInteraction.rawValue, object: nil)

            updateConversations()
        } else {
            NSNotificationCenter.defaultCenter().removeObserver(self,
                name: UIApplicationWillEnterForegroundNotification, object: nil)
        }
    }

    // MARK: public methods

    public func updateConversations() {

        delegate?.didStartRetrievingChatList(self, isFirstLoad: chatCount < 1)

        chatManager.retrieveChatsWithCompletion { [weak self] (result) in

            if let strongSelf = self {
                if let chats = result.value {
                    strongSelf.chats = chats
                    strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, nonEmptyChatList: chats.count > 0)
                } else if let actualError = result.error {
                    strongSelf.delegate?.didFailRetrievingChatList(strongSelf, error: actualError)
                }
            }
        }
        updateUnreadMessagesCount()
    }

    public func updateUnreadMessagesCount() {
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public func chatAtIndex(index: Int) -> Chat? {
        guard let chats = chats where index < chatCount else { return nil }
        return chats[index]
    }

}