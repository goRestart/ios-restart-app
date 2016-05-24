//
//  ChatRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 12/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result


public typealias ChatsResult = Result<[Chat], RepositoryError>
public typealias ChatsCompletion = ChatsResult -> Void

public typealias ChatResult = Result<Chat, RepositoryError>
public typealias ChatCompletion = ChatResult -> Void

public typealias MessageResult = Result<Message, RepositoryError>
public typealias MessageCompletion = MessageResult -> Void


public class OldChatRepository {
    let dataSource: OldChatDataSource
    let myUserRepository: MyUserRepository
    
    
    // MARK: Lifecycle
    
    init(dataSource: OldChatDataSource, myUserRepository: MyUserRepository) {
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
                forbidden: false,
                archivedStatus: .Active)
        }
        return nil
    }
    
    
    // MARK: Index methods
    
    /**
     Retrieves chats of the current user filtered by ChatsType
     The request is paginated with 20 results per page
     
     - parameter type: Chat type to filter the results
     - parameter page: Page you want to retrieve (starting in 0)
     - parameter numResults: Number of results per page, if nil the API will use the default value
     - parameter completion: Closure to execute when the operation finishes
     */
    public func index(type: ChatsType, page: Int, numResults: Int?, completion: ChatsCompletion?) {
        dataSource.index(type, page: page, numResults: numResults) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    
    // MARK: Show Methods
    
    /**
     Retrieves a chat for the given product and buyer.
     
     - parameter product: The product.
     - parameter buyer: The buyer.
     - parameter completion: The completion closure.
     */
    public func retrieveMessagesWithProduct(product: Product, buyer: User, page: Int = 0, numResults: Int,
                                            completion: ChatCompletion?) {
        if let productId = product.objectId, buyerId = buyer.objectId {
            retrieveMessagesWithProductId(productId, buyerId: buyerId, page: page, numResults: numResults,
                                          completion: completion)
        } else {
            completion?(ChatResult(error: .NotFound))
        }
    }
    
    public func retrieveMessagesWithProductId(productId: String, buyerId: String, page: Int = 0, numResults: Int,
                                              completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithProductId(productId, buyerId: buyerId, offset: page * numResults,
                                                 numResults: numResults) { result in
                                                    handleApiResult(result, completion: completion)
        }
    }
    
    public func retrieveMessagesWithConversationId(conversationId: String, page: Int = 0, numResults: Int,
                                                   completion: ChatCompletion?) {
        dataSource.retrieveMessagesWithConversationId(conversationId, offset: page * numResults,
                                                      numResults: numResults) { result in
                                                        handleApiResult(result, completion: completion)
        }
    }
    
    /**
     Retrieves the unread message count.
     
     - parameter completion: The completion closure.
     */
    public func retrieveUnreadMessageCountWithCompletion(completion: (Result<Int, RepositoryError> -> Void)?) {
        dataSource.fetchUnreadCount { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    
    // MARK: Post methods
    
    /**
     Sends a text message to given recipient for the given product.
     
     - parameter message: The message.
     - parameter product: The product.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    public func sendText(message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Text, message: message, product: product, recipient: recipient, completion: completion)
    }
    
    /**
     Sends an offer to given recipient for the given product.
     
     - parameter message: The message.
     - parameter product: The product.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    public func sendOffer(message: String, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Offer, message: message, product: product, recipient: recipient, completion: completion)
    }
    
    /**
     Sends a sticker to given recipient for the given product.
     
     - parameter sticker: The sticker object to send.
     - parameter product: The product.
     - parameter recipient: The recipient user.
     - parameter completion: The completion closure.
     */
    public func sendSticker(sticker: Sticker, product: Product, recipient: User, completion: MessageCompletion?) {
        sendMessage(.Sticker, message: sticker.name, product: product, recipient: recipient, completion: completion)
    }
    
    /**
     Archives a bunch of chats for the current user
     
     - parameter ids: The chats to be archived
     - parameter completion: The completion closure.
     */
    public func archiveChatsWithIds(ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.archiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    
    // MARK: - Put methods
    
    /**
     Unarchives a bunch of chats for the current user
     
     - parameter ids: The chats to be archived
     - parameter completion: The completion closure.
     */
    public func unarchiveChatsWithIds(ids: [String], completion: ((Result<Void, RepositoryError>) -> ())?) {
        dataSource.unarchiveChatsWithIds(ids) { result in
            handleApiResult(result, completion: completion)
        }
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
    public func sendMessage(messageType: MessageType, message: String, product: Product, recipient: User,
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
