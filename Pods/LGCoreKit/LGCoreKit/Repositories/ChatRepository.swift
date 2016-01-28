//
//  ChatRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 12/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public class ChatRepository {
    let dataSource: ChatDataSource
    let myUserRepository: MyUserRepository


    // MARK: Lifecycle

    init(dataSource: ChatDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }


    // MARK: Public methods

    /**
    Factory method. Will build a new chat from the provided product. Will use myUser as 'userFrom'.

    - returns: Chat in case myUser and product.user have values. nil otherwise
    */
    public func newChatWithProduct(product: Product) -> Chat? {
        if let myUser = myUserRepository.myUser {
            return LGChat(
                objectId: nil,
                updatedAt: NSDate(),
                product: product,
                userFrom: myUser,
                userTo: product.user,
                msgUnreadCount: 0,
                messages: [],
                forbidden: false)
        }
        return nil
    }

    /**
    Retrieves the chats.

    - parameter completion: The completion closure.
    */
    public func retrieveChatsWithCompletion(completion: (Result<[Chat], RepositoryError> -> Void)?) {
        dataSource.retrieveChats { (result: Result<[Chat], ApiError>) -> () in
            if let value = result.value {
                completion?(Result<[Chat], RepositoryError>(value: value))
            } else if let error = result.error {
                completion?(Result<[Chat], RepositoryError>(error: RepositoryError(apiError: error)))
            }
        }
    }


    /**
    Retrieves a chat for the given product and buyer.

    - parameter product: The product.
    - parameter buyer: The buyer.
    - parameter completion: The completion closure.
    */
    public func retrieveChatWithProduct(product: Product, buyer: User,
        completion: (Result<Chat, RepositoryError> -> Void)?) {
            if let productId = product.objectId, buyerId = buyer.objectId {
                retrieveChatWithProductId(productId, buyerId: buyerId, completion: completion)
            } else {
                completion?(Result<Chat, RepositoryError>(error: .NotFound))
            }
    }

    public func retrieveChatWithProductId(productId: String, buyerId: String,
        completion: (Result<Chat, RepositoryError> -> Void)?) {

            dataSource.retrieveChatWithProductId(productId, buyerId: buyerId) { (result: Result<Chat, ApiError>) -> () in
                if let value = result.value {
                    completion?(Result<Chat, RepositoryError>(value: value))
                } else if let error = result.error {
                    completion?(Result<Chat, RepositoryError>(error: RepositoryError(apiError: error)))
                }
            }
    }

    /**
    Retrieves the unread message count.

    - parameter completion: The completion closure.
    */
    public func retrieveUnreadMessageCountWithCompletion(completion: (Result<Int, RepositoryError> -> Void)?) {
        dataSource.fetchUnreadCount { (result: Result<Int, ApiError>) -> () in
            if let value = result.value {
                completion?(Result<Int, RepositoryError>(value: value))
            } else if let error = result.error {
                completion?(Result<Int, RepositoryError>(error: RepositoryError(apiError: error)))
            }
        }
    }

    /**
    Archives a chat for the current user

    - parameter chat: The chat to be archived
    - parameter completion: The completion closure.
    */
    public func archiveChatWithId(chat: Chat, completion: ((Result<Void, RepositoryError>) -> ())?) {
        guard let chatId = chat.objectId else {
            completion?(Result<Void, RepositoryError>(error: .Internal(message:"Chat doesn't have an Id")))
            return
        }
        dataSource.archiveChatWithId(chatId) { (result: Result<Void, ApiError>) -> () in
            if let error = result.error {
                completion?(Result<Void, RepositoryError>(error: RepositoryError(apiError: error)))
            } else {
                completion?(Result<Void, RepositoryError>(value: Void()))
            }
        }
    }

    /**
    Sends a text message to given recipient for the given product.

    - parameter message: The message.
    - parameter product: The product.
    - parameter recipient: The recipient user.
    - parameter completion: The completion closure.
    */
    public func sendText(message: String, product: Product, recipient: User,
        completion: (Result<Message, RepositoryError> -> Void)?) {
            sendMessage(.Text, message: message, product: product, recipient: recipient, completion: completion)
    }

    /**
    Sends an offer to given recipient for the given product.

    - parameter message: The message.
    - parameter product: The product.
    - parameter recipient: The recipient user.
    - parameter completion: The completion closure.
    */
    public func sendOffer(message: String, product: Product, recipient: User,
        completion: (Result<Message, RepositoryError> -> Void)?) {
            sendMessage(.Offer, message: message, product: product, recipient: recipient, completion: completion)
    }


    // MARK: - Private methods

    /**
    Sends a message to given recipient for the given product.

    - parameter messageType: The message type.
    - parameter message: The message.
    - parameter product: The product.
    - parameter recipient: The recipient user.
    - parameter completion: The completion closure.
    */
    private func sendMessage(messageType: MessageType, message: String, product: Product, recipient: User,
        completion: (Result<Message, RepositoryError> -> Void)?) {

            guard let myUser = self.myUserRepository.myUser?.objectId else {
                completion?(Result<Message, RepositoryError>(error: .Internal(message:"Non existant MyUser Id")))
                return
            }
            guard let recipientUserId = recipient.objectId, let productId = product.objectId else {
                completion?(Result<Message, RepositoryError>(error: .NotFound))
                return
            }

            dataSource.sendMessageTo(recipientUserId, productId: productId, message: message, type: messageType) {
                (result: Result<Void, ApiError>) -> () in
                if let error = result.error {
                    completion?(Result<Message, RepositoryError>(error: RepositoryError(apiError: error)))
                } else {
                    var msg = LGMessage()
                    msg.createdAt = NSDate()
                    msg.userId = myUser
                    msg.text = message
                    msg.type = messageType
                    completion?(Result<Message, RepositoryError>(value: msg))
                }
            }
    }
}
