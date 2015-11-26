//
//  ChatManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public class ChatManager {
    
    // Singleton
    public static let sharedInstance: ChatManager = ChatManager()
    
    // Managers
    public private(set) var myUserManager: MyUserManager
    
    // Services
    public private(set) var chatsRetrieveService: ChatsRetrieveService
    public private(set) var chatRetrieveService: ChatRetrieveService
    public private(set) var chatsUnreadCountRetrieveService: ChatsUnreadCountRetrieveService
    public private(set) var chatSendMessageService: ChatSendMessageService
    
    // Data
    public private(set) var chats: [Chat]
    public private(set) var loadingChats: Bool
    
    public private(set) var unreadMsgCount: Int
    public private(set) var loadingUnreadCount: Bool
    
    // MARK: - Lifecycle
    
    private convenience init() {
        let myUserManager = MyUserManager.sharedInstance
        let chatsRetrieveService = LGChatsRetrieveService()
        let chatRetrieveService = LGChatRetrieveService()
        let chatsUnreadCountRetrieveService = LGChatsUnreadCountRetrieveService()
        let chatSendMessageService = LGChatSendMessageService()
        self.init(myUserManager: myUserManager, chatsRetrieveService: chatsRetrieveService, chatRetrieveService: chatRetrieveService, chatsUnreadCountRetrieveService: chatsUnreadCountRetrieveService, chatSendMessageService: chatSendMessageService)
    }
    
    public required init(myUserManager: MyUserManager, chatsRetrieveService: ChatsRetrieveService, chatRetrieveService: ChatRetrieveService, chatsUnreadCountRetrieveService: ChatsUnreadCountRetrieveService, chatSendMessageService: ChatSendMessageService) {
        // Managers
        self.myUserManager = myUserManager
        
        // Services
        self.chatsRetrieveService = chatsRetrieveService
        self.chatRetrieveService = chatRetrieveService
        self.chatsUnreadCountRetrieveService = chatsUnreadCountRetrieveService
        self.chatSendMessageService = chatSendMessageService
        
        // Data
        self.chats = []
        self.loadingChats = false
        
        self.unreadMsgCount = 0
        self.loadingUnreadCount = false
    }
    
    // MARK: - Public methods
    
    /**
    Factory method. Will build a new chat from the provided product. Will use myUser as 'userFrom'.
    
    - returns: Chat in case myUser and product.user have values. nil otherwise
    */
    public func newChatWithProduct(product: Product) -> Chat? {
        if let myUser = myUserManager.myUser(){
            return LGChat(
                objectId: nil,
                updatedAt: NSDate(),
                product: product,
                userFrom: myUser,
                userTo: product.user,
                msgUnreadCount: 0,
                messages: [])
        }
        return nil
    }
    
    /**
        Retrieves the chats.
    
        - parameter completion: The completion closure.
    */
    public func retrieveChatsWithCompletion(completion: (Result<[Chat], ChatsRetrieveServiceError> -> Void)?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            if !loadingChats {
                loadingChats = true
                
                chatsRetrieveService.retrieveChatsWithSessionToken(sessionToken) { [weak self] (myResult: ChatsRetrieveServiceResult) -> Void in
                    self?.loadingChats = false
                    
                    // Success
                    if let response = myResult.value {
                        let chats = response.chats
                        
                        // Keep track of the chats
                        self?.chats = chats
                        
                        // Notify
                        completion?(Result<[Chat], ChatsRetrieveServiceError>(value: chats))
                    }
                    // Error
                    else if let error = myResult.error {
                        completion?(Result<[Chat], ChatsRetrieveServiceError>(error: error))
                    }
                }
            }
            else {
                completion?(Result<[Chat], ChatsRetrieveServiceError>(error: .Internal))
            }
        }
        else {
            completion?(Result<[Chat], ChatsRetrieveServiceError>(error: .Unauthorized))
        }
    }
    
    /**
        Retrieves the unread message count.
    
        - parameter completion: The completion closure.
    */
    public func retrieveUnreadMessageCountWithCompletion(completion: ChatsUnreadCountRetrieveServiceCompletion?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            if !loadingUnreadCount {
                loadingUnreadCount = true
                
                chatsUnreadCountRetrieveService.retrieveUnreadMessageCountWithSessionToken(sessionToken) { [weak self] (myResult: ChatsUnreadCountRetrieveServiceResult) -> Void in
                    self?.loadingUnreadCount = false
                    
                    // Success
                    if let count = myResult.value {
                        
                        // Keep track of unread msg count
                        self?.unreadMsgCount = count
                        
                        // Notify
                        completion?(ChatsUnreadCountRetrieveServiceResult(value: count))
                    }
                    // Error
                    else if let error = myResult.error {
                        completion?(ChatsUnreadCountRetrieveServiceResult(error: error))
                    }
                }
            }
            else {
                completion?(ChatsUnreadCountRetrieveServiceResult(error: .Internal))
            }
        }
        else {
            completion?(ChatsUnreadCountRetrieveServiceResult(error: .Unauthorized))
        }
    }
    
    /**
        Retrieves a chat for the given product and buyer.
    
        - parameter product: The product.
        - parameter buyer: The buyer.
        - parameter completion: The completion closure.
    */
    public func retrieveChatWithProduct(product: Product, buyer: User, completion: (Result<Chat, ChatRetrieveServiceError> -> Void)?) {
        if let productId = product.objectId, buyerId = buyer.objectId {
            retrieveChatWithProductId(productId, buyerId: buyerId, completion: completion)
        }
        else {
            completion?(Result<Chat, ChatRetrieveServiceError>(error: .NotFound))
        }
    }
    
    /**
        Retrieves a chat with the given product id and buyer id.
    
        - parameter productId: The product identifier.
        - parameter buyerId: The buyer (user) identifier.
        - parameter completion: The completion closure.
    */
    public func retrieveChatWithProductId(productId: String, buyerId: String, completion: (Result<Chat, ChatRetrieveServiceError> -> Void)?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            chatRetrieveService.retrieveChatWithSessionToken(sessionToken, productId: productId, buyerId: buyerId) { (myResult: ChatRetrieveServiceResult) -> Void in
                
                // Success
                if let chatResponse = myResult.value {
                    completion?(Result<Chat, ChatRetrieveServiceError>(value: chatResponse.chat))
                }
                // Error
                else if let error = myResult.error {
                    completion?(Result<Chat, ChatRetrieveServiceError>(error: error))
                }
            }
        }
        else {
            completion?(Result<Chat, ChatRetrieveServiceError>(error: .Unauthorized))
        }
    }
    
    /**
        Sends a text message to given recipient for the given product.
    
        - parameter message: The message.
        - parameter product: The product.
        - parameter recipient: The recipient user.
        - parameter completion: The completion closure.
    */
    public func sendText(message: String, product: Product, recipient: User, completion: ChatSendMessageServiceCompletion?) {
        sendMessage(.Text, message: message, product: product, recipient: recipient, completion: completion)
    }
    
    /**
        Sends an offer to given recipient for the given product.
    
        - parameter message: The message.
        - parameter product: The product.
        - parameter recipient: The recipient user.
        - parameter completion: The completion closure.
    */
    public func sendOffer(message: String, product: Product, recipient: User, completion: ChatSendMessageServiceCompletion?) {
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
    private func sendMessage(messageType: MessageType, message: String, product: Product, recipient: User, completion: ChatSendMessageServiceCompletion?) {
        if let myUser = myUserManager.myUser(), let sessionToken = myUser.sessionToken, let myUserId = myUser.objectId {
            if let recipientUserId = recipient.objectId, let productId = product.objectId {
                chatSendMessageService.sendMessageWithSessionToken(sessionToken, userId: myUserId, message: message, type: messageType, recipientUserId: recipientUserId, productId: productId, completion: completion)
            }
            else {
                completion?(ChatSendMessageServiceResult(error: .NotFound))
            }
        }
        else {
            completion?(ChatSendMessageServiceResult(error: .Unauthorized))
        }
    }
}