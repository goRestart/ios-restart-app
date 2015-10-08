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
        Retrieves the chats.
    
        :param: completion The completion closure.
    */
    public func retrieveChats(completion: (Result<[Chat], ChatsRetrieveServiceError> -> Void)?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            if !loadingChats {
                loadingChats = true
                
                chatsRetrieveService.retrieveChatsWithSessionToken(sessionToken) { [weak self] (myResult: Result<ChatsResponse, ChatsRetrieveServiceError>) -> Void in
                    self?.loadingChats = false
                    
                    // Success
                    if let response = myResult.value {
                        let chats = response.chats
                        
                        // Keep track of the chats
                        self?.chats = chats
                        
                        // Notify
                        completion?(Result<[Chat], ChatsRetrieveServiceError>.success(chats))
                    }
                    // Error
                    else if let error = myResult.error {
                        completion?(Result<[Chat], ChatsRetrieveServiceError>.failure(error))
                    }
                }
            }
            else {
                completion?(Result<[Chat], ChatsRetrieveServiceError>.failure(.Internal))
            }
        }
        else {
            completion?(Result<[Chat], ChatsRetrieveServiceError>.failure(.Unauthorized))
        }
    }
    
    /**
        Retrieves the unread message count.
    
        :param: completion The completion closure.
    */
    public func retrieveUnreadMessageCount(completion: (Result<Int, ChatsUnreadCountRetrieveServiceError> -> Void)?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            if !loadingUnreadCount {
                loadingUnreadCount = true
                
                chatsUnreadCountRetrieveService.retrieveUnreadMessageCountWithSessionToken(sessionToken) { [weak self] (myResult: Result<Int, ChatsUnreadCountRetrieveServiceError>) -> Void in
                    self?.loadingUnreadCount = false
                    
                    // Success
                    if let count = myResult.value {
                        
                        // Keep track of unread msg count
                        self?.unreadMsgCount = count
                        
                        // Notify
                        completion?(Result<Int, ChatsUnreadCountRetrieveServiceError>.success(count))
                    }
                    // Error
                    else if let error = myResult.error {
                        completion?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(error))
                    }
                }
            }
            else {
                completion?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Internal))
            }
        }
        else {
            completion?(Result<Int, ChatsUnreadCountRetrieveServiceError>.failure(.Unauthorized))
        }
    }
    
    /**
        Retrieves a chat for the given product and buyer.
    
        :param: product The product.
        :param: buyer The buyer.
        :param: completion The completion closure.
    */
    public func retrieveChatWithProduct(product: Product, buyer: User, completion: (Result<Chat, ChatRetrieveServiceError> -> Void)?) {
        if let sessionToken = myUserManager.myUser()?.sessionToken {
            if let productId = product.objectId, buyerId = buyer.objectId {
                chatRetrieveService.retrieveChatWithSessionToken(sessionToken, productId: productId, buyerId: buyerId) { [weak self] (myResult: Result<ChatResponse, ChatRetrieveServiceError>) -> Void in
                    
                    // Success
                    if let chatResponse = myResult.value {
                        completion?(Result<Chat, ChatRetrieveServiceError>.success(chatResponse.chat))
                    }
                    // Error
                    else if let error = myResult.error {
                        completion?(Result<Chat, ChatRetrieveServiceError>.failure(error))
                    }
                }
            }
            else {
                completion?(Result<Chat, ChatRetrieveServiceError>.failure(.NotFound))
            }
        }
        else {
            completion?(Result<Chat, ChatRetrieveServiceError>.failure(.Unauthorized))
        }
    }
    
    
    /**
        Sends a text message to given recipient for the given product.
    
        :param: message The message.
        :param: product The product.
        :param: recipient The recipient user.
        :param: completion The completion closure.
    */
    public func sendText(message: String, product: Product, recipient: User, completion: (Result<Message, ChatSendMessageServiceError> -> Void)?) {
        sendMessage(.Text, message: message, product: product, recipient: recipient, completion: completion)
    }
    
    /**
        Sends an offer to given recipient for the given product.
    
        :param: message The message.
        :param: product The product.
        :param: recipient The recipient user.
        :param: completion The completion closure.
    */
    public func sendOffer(message: String, product: Product, recipient: User, completion: (Result<Message, ChatSendMessageServiceError> -> Void)?) {
        sendMessage(.Offer, message: message, product: product, recipient: recipient, completion: completion)
    }
    
    // MARK: - Private methods
    
    /**
        Sends a message to given recipient for the given product.
    
        :param: messageType The message type.
        :param: message The message.
        :param: product The product.
        :param: recipient The recipient user.
        :param: completion The completion closure.
    */
    private func sendMessage(messageType: MessageType, message: String, product: Product, recipient: User, completion: (Result<Message, ChatSendMessageServiceError> -> Void)?) {
        if let myUser = myUserManager.myUser(), let sessionToken = myUser.sessionToken, let myUserId = myUser.objectId {
            if let recipientUserId = recipient.objectId, let productId = product.objectId {
                chatSendMessageService.sendMessageWithSessionToken(sessionToken, userId: myUserId, message: message, type: messageType, recipientUserId: recipientUserId, productId: productId, result: completion)
            }
            else {
                completion?(Result<Message, ChatSendMessageServiceError>.failure(.NotFound))
            }
        }
        else {
            completion?(Result<Message, ChatSendMessageServiceError>.failure(.Unauthorized))
        }
    }
}