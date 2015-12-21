//
//  ChatListViewModel.swift
//  LetGo
//
//  Created by Dídac on 21/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

public protocol ChatListViewModelDelegate: class {
    func didStartRetrievingChatList(viewModel: ChatListViewModel, isFirstLoad: Bool)
    func didFailRetrievingChatList(viewModel: ChatListViewModel, error: ChatsRetrieveServiceError)
    func didSucceedRetrievingChatList(viewModel: ChatListViewModel, nonEmptyChatList: Bool)
}

public class ChatListViewModel : BaseViewModel {

    public weak var delegate : ChatListViewModelDelegate?

    var chats: [Chat]?
    var chatManager: ChatManager

    // - computed iVars
    var chatCount : Int {
        return chats?.count ?? 0
    }

    // - Lifecycle

    public override convenience init() {
        self.init(chatManager: ChatManager.sharedInstance, chats: [])
    }

    public required init(chatManager: ChatManager, chats: [Chat]) {
        self.chatManager = chatManager
        self.chats = chats
        super.init()
    }


    // MARK: public methods

    public func updateConversations() {

        delegate?.didStartRetrievingChatList(self, isFirstLoad: chatCount < 1)

        chatManager.retrieveChatsWithCompletion({
            [weak self] (result: Result<[Chat], ChatsRetrieveServiceError>) -> Void in

            if let strongSelf = self {
                // Success
                if let chats = result.value {
                    strongSelf.chats = chats
                    strongSelf.delegate?.didSucceedRetrievingChatList(strongSelf, nonEmptyChatList: chats.count > 0)
                } else if let actualError = result.error {
                    strongSelf.delegate?.didFailRetrievingChatList(strongSelf, error: actualError)
                }
            }
        })
    }

    public func updateUnreadMessagesCount() {
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public func chatAtIndex(index: Int) -> Chat? {
        guard let chats = chats else { return nil }
        return chats[index]
    }
}