//
//  ChatWebSocketDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 18/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import Argo


class ChatWebSocketDataSource: ChatDataSource {
    
    let webSocketClient: WebSocketClient
    let webSocketMessageRouter = WebSocketMessageRouter(uuidGenerator: LGUUID())
    let webSocketConversationRouter = WebSocketConversationRouter(uuidGenerator: LGUUID())
    let webSocketEventRouter = WebSocketEventRouter(uuidGenerator: LGUUID())
    let webSocketCommandRouter = WebSocketCommandRouter(uuidGenerator: LGUUID())

    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(webSocketClient: WebSocketClient, apiClient: ApiClient) {
        self.webSocketClient = webSocketClient
        self.apiClient = apiClient
    }
    
    
    // MARK: - Messages
    
    func indexMessages(conversationId: String, numResults: Int, offset: Int,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.index(conversationId, limit: numResults, offset: offset)
            webSocketClient.sendQuery(request) { [weak self] result in
                self?.handleMessagesResult(result, completion: completion)
            }
    }
    
    func indexMessagesNewerThan(messageId: String, conversationId: String,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.indexNewerThan(messageId, conversationId: conversationId)
            webSocketClient.sendQuery(request) { [weak self] result in
                self?.handleMessagesResult(result, completion: completion)
            }
    }
    
    func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int,
        completion: ChatWebSocketMessagesCompletion?) {
            let request = webSocketMessageRouter.indexOlderThan(messageId, conversationId: conversationId,
                limit: numResults)
            webSocketClient.sendQuery(request) { [weak self] result in
                self?.handleMessagesResult(result, completion: completion)
            }
    }
    
    private func handleMessagesResult(result: Result<[String : AnyObject], WebSocketError>,
        completion: ChatWebSocketMessagesCompletion?) {
            if let value = result.value {
                let messages = ChatModelsMapper.messagesFromDict(value)
                completion?(ChatWebSocketMessagesResult(value: messages))
            } else if let error = result.error {
                completion?(ChatWebSocketMessagesResult(error: error))
            }
    }
    
    
    // MARK: - Conversations
    
    func indexConversations(numResults: Int, offset: Int, filter: WebSocketConversationFilter,
        completion: ChatWebSocketConversationsCompletion?) {
            let request = webSocketConversationRouter.index(numResults, offset: offset, filter: filter)
            webSocketClient.sendQuery(request) { result in
                if let value = result.value {
                    let conversations = ChatModelsMapper.conversationsFromDict(value)
                    completion?(ChatWebSocketConversationsResult(value: conversations))
                } else if let error = result.error {
                    completion?(ChatWebSocketConversationsResult(error: error))
                }
            }
    }
    
    func showConversation(conversationId: String, completion: ChatWebSocketConversationCompletion?) {
        let request = webSocketConversationRouter.show(conversationId)
        webSocketClient.sendQuery(request) { result in
            if let value = result.value, let conversation = ChatModelsMapper.conversationFromDict(value) {
                completion?(ChatWebSocketConversationResult(value: conversation))
            } else if let error = result.error {
                completion?(ChatWebSocketConversationResult(error: error))
            }
        }
    }
    
    func showConversation(sellerId: String, productId: String, completion: ChatWebSocketConversationCompletion?) {
        let request = webSocketConversationRouter.show(sellerId, productId: productId)
        webSocketClient.sendQuery(request) { result in
            if let value = result.value, let conversation = ChatModelsMapper.conversationFromDict(value) {
                completion?(ChatWebSocketConversationResult(value: conversation))
            } else if let error = result.error {
                completion?(ChatWebSocketConversationResult(error: error))
            }
        }
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


    // MARK: - Unread messages

    func unreadMessages(userId: String, completion: ChatWebSocketUnreadCountCompletion?) {
        let request = ChatRouter.UnreadCount(userId: userId)
        apiClient.request(request, decoder: chatUnreadMessagesDecoder, completion: completion)
    }


    // MARK: - Private

    /**
     Decodes an object to a `ChatUnreadMessages` object.
     - parameter object: The object.
     - returns: A `ChatUnreadMessages` object.
     */
    private func chatUnreadMessagesDecoder(object: AnyObject) -> ChatUnreadMessages? {
        let result: Decoded<LGChatUnreadMessages> = JSON(object) <| "data"
        return result.value
    }
}
