//
//  LGOldChatRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

class LGOldChatRepository: OldChatRepository {
    let dataSource: OldChatDataSource
    let myUserRepository: MyUserRepository


    // MARK: Lifecycle

    init(dataSource: OldChatDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }


    // MARK: Public methods

    func newChatWithProduct(product: Product) -> Chat? {
        if let myUser = myUserRepository.myUser {
            return LGChat(
                objectId: nil,
                updatedAt: NSDate(),
                product: product,
                userFrom: myUser,
                userTo: product.user,
                msgUnreadCount: 0,
                messages: [],
                forbidden: false,
                archivedStatus: .Active)
        }
        return nil
    }


    // MARK: Index methods

    func index(type: ChatsType, page: Int, numResults: Int?, completion: ChatsCompletion?) {
        dataSource.index(type, page: page, numResults: numResults) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: Show Methods

    func retrieveMessagesWithProduct(product: Product, buyer: User, page: Int, numResults: Int,
                                     completion: ChatCompletion?) {
        if let productId = product.objectId, buyerId = buyer.objectId {
            retrieveMessagesWithProductId(productId, buyerId: buyerId, page: page, numResults: numResults,
                                          completion: completion)
        } else {
            completion?(ChatResult(error: .NotFound))
        }
    }

    func retrieveMessagesWithProductId(productId: String, buyerId: String, page: Int, numResults: Int,
                                       completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithProductId(productId, buyerId: buyerId, offset: page * numResults,
                                                 numResults: numResults) { result in
                                                    handleApiResult(result, completion: completion)
        }
    }

    func retrieveMessagesWithConversationId(conversationId: String, page: Int, numResults: Int,
                                            completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithConversationId(conversationId, offset: page * numResults,
                                                      numResults: numResults) { result in
                                                        handleApiResult(result, completion: completion)
        }
    }

    func retrieveUnreadMessageCountWithCompletion(completion: (Result<Int, RepositoryError> -> Void)?) {
        dataSource.fetchUnreadCount { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: Post methods

    func sendText(message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Text, message: message, product: product, recipient: recipient, completion: completion)
    }

    func sendOffer(message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Offer, message: message, product: product, recipient: recipient, completion: completion)
    }

    func sendSticker(sticker: Sticker, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Sticker, message: sticker.name, product: product, recipient: recipient, completion: completion)
    }

    func archiveChatsWithIds(ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.archiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Put methods

    func unarchiveChatsWithIds(ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.unarchiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Private methods

    func sendMessage(messageType: MessageType, message: String, product: Product, recipient: User,
                     completion: MessageCompletion?) {

        guard let myUser = self.myUserRepository.myUser?.objectId else {
            completion?(Result<Message, RepositoryError>(error: .Internal(message:"Non existant MyUser Id")))
            return
        }
        guard let recipientUserId = recipient.objectId, let productId = product.objectId else {
            completion?(Result<Message, RepositoryError>(error: .NotFound))
            return
        }

        dataSource.sendMessageTo(recipientUserId, productId: productId, message: message, type: messageType) {
            result in
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

