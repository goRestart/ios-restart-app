//
//  MockOldChatRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import Result

class MockOldChatRepository: OldChatRepository {

    var chatsResult: ChatsResult?
    var chatResult: ChatResult?
    var messageResult: MessageResult?
    var unreadMessagesResult: Result<Int, RepositoryError>?
    var unreadMessagesCompletion: ((Result<Int, RepositoryError>) -> Void)?
    var voidResult: Result<Void, RepositoryError>?

    func newChatWithProduct(_ product: Product) -> Chat? {
        return nil
    }

    func index(_ type: ChatsType, page: Int, numResults: Int?, completion: ChatsCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatsResult)
    }

    func retrieveMessagesWithProduct(_ product: Product, buyer: User, page: Int, numResults: Int,
                                     completion: ChatCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatResult)
    }

    func retrieveMessagesWithProductId(_ productId: String, buyerId: String, page: Int, numResults: Int,
                                       completion: ChatCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatResult)
    }

    func retrieveMessagesWithConversationId(_ conversationId: String, page: Int, numResults: Int,
                                            completion: ChatCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatResult)
    }

    func retrieveUnreadMessageCountWithCompletion(_ completion: ((Result<Int, RepositoryError>) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) { [weak self] in
            guard let result = self?.unreadMessagesResult else { return }
            completion?(result)
            self?.unreadMessagesCompletion?(result)
        }
    }


    func sendText(_ message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        performAfterDelayWithCompletion(completion, result: messageResult)
    }

    func sendOffer(_ message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        performAfterDelayWithCompletion(completion, result: messageResult)
    }

    func sendSticker(_ sticker: Sticker, product: Product, recipient: User, completion: MessageCompletion?) {
        performAfterDelayWithCompletion(completion, result: messageResult)
    }

    func archiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        performAfterDelayWithCompletion(completion, result: voidResult)
    }

    func unarchiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        performAfterDelayWithCompletion(completion, result: voidResult)
    }

    func sendMessage(_ messageType: MessageType, message: String, product: Product, recipient: User,
                     completion: MessageCompletion?) {
        performAfterDelayWithCompletion(completion, result: messageResult)
    }
}
