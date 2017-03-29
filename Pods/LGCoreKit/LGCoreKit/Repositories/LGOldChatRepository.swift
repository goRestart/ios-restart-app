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

    func newChatWithProduct(_ product: Product) -> Chat? {
        if let myUser = myUserRepository.myUser {
            let myUserProduct = LGUserListing(user: myUser)
            return LGChat(
                objectId: nil,
                updatedAt: Date(),
                listing: Listing.product(product),
                userFrom: myUserProduct,
                userTo: product.user,
                msgUnreadCount: 0,
                messages: [],
                forbidden: false,
                archivedStatus: .active)
        }
        return nil
    }


    // MARK: Index methods

    func index(_ type: ChatsType, page: Int, numResults: Int?, completion: ChatsCompletion?) {
        dataSource.index(type, page: page, numResults: numResults) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: Show Methods

    func retrieveMessagesWithProduct(_ product: Product, buyer: User, page: Int, numResults: Int,
                                     completion: ChatCompletion?) {
        if let productId = product.objectId, let buyerId = buyer.objectId {
            retrieveMessagesWithProductId(productId, buyerId: buyerId, page: page, numResults: numResults,
                                          completion: completion)
        } else {
            completion?(ChatResult(error: .notFound))
        }
    }

    func retrieveMessagesWithProductId(_ productId: String, buyerId: String, page: Int, numResults: Int,
                                       completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithProductId(productId, buyerId: buyerId, offset: page * numResults,
                                                 numResults: numResults) { result in
                                                    handleApiResult(result, completion: completion)
        }
    }

    func retrieveMessagesWithConversationId(_ conversationId: String, page: Int, numResults: Int,
                                            completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithConversationId(conversationId, offset: page * numResults,
                                                      numResults: numResults) { result in
                                                        handleApiResult(result, completion: completion)
        }
    }

    func retrieveUnreadMessageCountWithCompletion(_ completion: ((Result<Int, RepositoryError>) -> Void)?) {
        dataSource.fetchUnreadCount { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: Post methods

    func sendText(_ message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        guard let recipientId = recipient.objectId, let productId = product.objectId else {
            completion?(Result<Message, RepositoryError>(error: .notFound))
            return
        }
        sendText(message, listingId: productId, recipientId: recipientId, completion: completion)
    }

    func sendText(_ message: String, listingId: String, recipientId: String, completion: MessageCompletion?) {
        sendMessage(.text, message: message, listingId: listingId, recipientId: recipientId, completion: completion)
    }

    func sendOffer(_ message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        guard let recipientId = recipient.objectId, let productId = product.objectId else {
            completion?(Result<Message, RepositoryError>(error: .notFound))
            return
        }
        sendOffer(message, listingId: productId, recipientId: recipientId, completion: completion)
    }

    func sendOffer(_ message: String, listingId: String, recipientId: String, completion: MessageCompletion?) {
        sendMessage(.offer, message: message, listingId: listingId, recipientId: recipientId, completion: completion)
    }

    func sendSticker(_ sticker: Sticker, product: Product, recipient: User, completion: MessageCompletion?) {
        guard let recipientId = recipient.objectId, let productId = product.objectId else {
            completion?(Result<Message, RepositoryError>(error: .notFound))
            return
        }
        sendSticker(sticker, listingId: productId, recipientId: recipientId, completion: completion)
    }

    func sendSticker(_ sticker: Sticker, listingId: String, recipientId: String, completion: MessageCompletion?) {
        sendMessage(.sticker, message: sticker.name, listingId: listingId, recipientId: recipientId, completion: completion)
    }

    func archiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.archiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Put methods

    func unarchiveChatsWithIds(_ ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.unarchiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
    }


    // MARK: - Private methods

    func sendMessage(_ messageType: MessageType, message: String, listingId: String, recipientId: String,
                     completion: MessageCompletion?) {

        guard let myUser = self.myUserRepository.myUser?.objectId else {
            completion?(Result<Message, RepositoryError>(error: .internalError(message:"Non existant MyUser Id")))
            return
        }

        dataSource.sendMessageTo(recipientId, productId: listingId, message: message, type: messageType) {
            result in
            if let error = result.error {
                completion?(Result<Message, RepositoryError>(error: RepositoryError(apiError: error)))
            } else {
                var msg = LGMessage()
                msg.createdAt = Date()
                msg.userId = myUser
                msg.text = message
                msg.type = messageType
                completion?(Result<Message, RepositoryError>(value: msg))
            }
        }
    }
}

