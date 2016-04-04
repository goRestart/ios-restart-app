//
//  NewChatRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias ChatMessagesResult = Result<[ChatMessage], RepositoryError>
public typealias ChatMessagesCompletion = ChatMessagesResult -> Void

public typealias ChatConversationsResult = Result<[ChatConversation], RepositoryError>
public typealias ChatConversationsCompletion = ChatConversationsResult -> Void

public typealias ChatConversationResult = Result<ChatConversation, RepositoryError>
public typealias ChatConversationCompletion = ChatConversationResult -> Void

public typealias ChatCommandResult = Result<Void, RepositoryError>
public typealias ChatCommandCompletion = ChatCommandResult -> Void


public class ChatRepository {
    let dataSource: ChatDataSource
    let myUserRepository: MyUserRepository
    
    init(dataSource: ChatDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }
    
    
    // MARK: > Public Methods
    // MARK: - Messages
    
    public func indexMessages(conversationId: String, numResults: Int, offset: Int,
        completion: ChatMessagesCompletion?) {
            dataSource.indexMessages(conversationId, numResults: numResults, offset: offset) { result in
                handleWebSocketResult(result, completion: completion)
            }
    }
    
    public func indexMessagesNewerThan(messageId: String, conversationId: String, completion: ChatMessagesCompletion?) {
        dataSource.indexMessagesNewerThan(messageId, conversationId: conversationId) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    public func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int,
        completion: ChatMessagesCompletion?) {
            dataSource.indexMessagesOlderThan(messageId, conversationId: conversationId, numResults: numResults) {
                result in
                handleWebSocketResult(result, completion: completion)
            }
    }
    
    
    // MARK: - Conversations
    
    public func indexConversations(numResults: Int, offset: Int, filter: WebSocketConversationFilter,
        completion: ChatConversationsCompletion?) {
            dataSource.indexConversations(numResults, offset: offset, filter: filter) { result in
                handleWebSocketResult(result, completion: completion)
            }
    }
    
    public func showConversation(conversationId: String, completion: ChatConversationCompletion?) {
        dataSource.showConversation(conversationId) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    public func showConversation(sellerId: String, productId: String, completion: ChatConversationCompletion?) {
        dataSource.showConversation(sellerId, productId: productId) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    
    // MARK: - Events
    
    public func typingStarted(conversationId: String) {
        dataSource.typingStarted(conversationId)
    }
    
    public func typingStopped(conversationId: String) {
        dataSource.typingStopped(conversationId)
    }
    
    
    // MARK: - Commands
    
    internal func authenticate(authToken: String, completion: ChatCommandCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(Result<Void, RepositoryError>(error: .Internal(message: "Missing myUserId")))
            return
        }
        dataSource.authenticate(userId, authToken: authToken) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    public func sendMessage(conversationId: String, messageId: String, type: ChatMessageType, text: String,
        completion: ChatCommandCompletion?) {
            dataSource.sendMessage(conversationId, messageId: messageId, type: type.rawValue, text: text) { result in
                handleWebSocketResult(result, completion: completion)
            }
    }
    
    public func confirmReception(conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmReception(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    public func confirmRead(conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmRead(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    public func archiveConversations(conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.archiveConversations(conversationIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func unarchiveConversations(conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.unarchiveConversations(conversationIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
}
