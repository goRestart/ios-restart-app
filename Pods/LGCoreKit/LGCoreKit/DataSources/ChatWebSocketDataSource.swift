//
//  ChatWebSocketDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 18/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

class ChatWebSocketDataSource: ChatDataSource {
    
    let webSocketClient: WebSocketClient
    let webSocketMessageRouter = WebSocketMessageRouter(uuidGenerator: LGUUID())
    let webSocketConversationRouter = WebSocketConversationRouter(uuidGenerator: LGUUID())
    let webSocketEventRouter = WebSocketEventRouter(uuidGenerator: LGUUID())
    let webSocketCommandRouter = WebSocketCommandRouter(uuidGenerator: LGUUID())
    
    
    // MARK: - Lifecycle
    
    init(webSocketClient: WebSocketClient) {
        self.webSocketClient = webSocketClient
    }
    
    
    // MARK: - Messages
    // TODO: Parse [String: AnyObject] to Models
    
    func indexMessages(conversationId: String, numResults: Int, offset: Int,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.index(conversationId, limit: numResults, offset: offset)
            webSocketClient.sendQuery(request, completion: nil)
    }
    
    func indexMessagesNewerThan(messageId: String, conversationId: String,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.indexNewerThan(messageId, conversationId: conversationId)
            webSocketClient.sendQuery(request, completion: nil)
    }
    
    func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.indexOlderThan(messageId, conversationId: conversationId,
                limit: numResults)
            webSocketClient.sendQuery(request, completion: nil)
    }
    
    
    // MARK: - Conversations
    
    func indexConversations(numResults: Int, offset: Int, filter: WebSocketConversationFilter,
        completion: ChatWebSocketConversationsCompletion?) {
            let request = webSocketConversationRouter.index(numResults, offset: offset, filter: filter)
            webSocketClient.sendQuery(request, completion: nil)
    }
    
    func showConversation(conversationId: String, completion: ChatWebSocketConversationCompletion?) {
        let request = webSocketConversationRouter.show(conversationId)
        webSocketClient.sendQuery(request, completion: nil)
    }
    
    func createConversation(sellerId: String, buyerId: String, productId: String,
        completion: ChatWebSocketConversationCompletion?) {
            let request = webSocketConversationRouter.createConversation(sellerId, buyerId: buyerId,
                productId: productId)
            webSocketClient.sendQuery(request, completion: nil)
    }
    
    
    // MARK: - Events
    
    func typingStarted(conversationId: String) {
        let request = webSocketEventRouter.typingStarted(conversationId)
        webSocketClient.sendEvent(request)
    }
    
    func typingStopped(conversationId: String) {
        let request = webSocketEventRouter.typingStopped(conversationId)
        webSocketClient.sendEvent(request)
    }
    
    
    // MARK: - Commands
    
    func authenticate(userId: String, authToken: String, completion: ChatWebSocketCommandCompletion?) {
        let request = webSocketCommandRouter.authenticate(userId, authToken: authToken)
        webSocketClient.sendCommand(request, completion: completion)
    }
    
    func sendMessage(conversationId: String, messageId: String, type: String, text: String,
        completion: ChatWebSocketCommandCompletion?) {
            let request = webSocketCommandRouter.sendMessage(conversationId, messageId: messageId, type: type,
                text: text)
            webSocketClient.sendCommand(request, completion: completion)
    }
    
    func confirmReception(conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?) {
        let request = webSocketCommandRouter.confirmReception(conversationId, messageIds: messageIds)
        webSocketClient.sendCommand(request, completion: completion)
    }
    
    func confirmRead(conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?) {
        let request = webSocketCommandRouter.confirmRead(conversationId, messageIds: messageIds)
        webSocketClient.sendCommand(request, completion: completion)
    }
    
    func archiveConversations(conversationIds: [String], completion: ChatWebSocketCommandCompletion?) {
        let request = webSocketCommandRouter.archiveConversations(conversationIds)
        webSocketClient.sendCommand(request, completion: completion)
    }
    
    func unarchiveConversations(conversationIds: [String], completion: ChatWebSocketCommandCompletion?) {
        let request = webSocketCommandRouter.unarchiveConversations(conversationIds)
        webSocketClient.sendCommand(request, completion: completion)
    }
}
