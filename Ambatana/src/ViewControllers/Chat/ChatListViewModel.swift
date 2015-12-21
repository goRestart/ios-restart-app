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

    // - Lifecycle

    override convenience init() {
        self.init()
    }


    func updateConversations() {

        let firstLoad: Bool
        if let actualChats = chats {
            firstLoad = actualChats.isEmpty
        } else {
            firstLoad = true
        }

        delegate?.didStartRetrievingChatList(self, isFirstLoad: firstLoad)

        ChatManager.sharedInstance.retrieveChatsWithCompletion({
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
}