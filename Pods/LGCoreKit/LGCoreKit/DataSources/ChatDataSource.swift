//
//  NewChatDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 18/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


import Result
import RxSwift

typealias ChatWebSocketMessagesResult = Result<[ChatMessage], WebSocketError>
typealias ChatWebSocketMessagesCompletion = ChatWebSocketMessagesResult -> Void

typealias ChatWebSocketConversationsResult = Result<[ChatConversation], WebSocketError>
typealias ChatWebSocketConversationsCompletion = ChatWebSocketConversationsResult -> Void

typealias ChatWebSocketConversationResult = Result<ChatConversation, WebSocketError>
typealias ChatWebSocketConversationCompletion = ChatWebSocketConversationResult -> Void

typealias ChatWebSocketCommandResult = Result<Void, WebSocketError>
typealias ChatWebSocketCommandCompletion = ChatWebSocketCommandResult -> Void

typealias ChatWebSocketUnreadCountResult = Result<ChatUnreadMessages, ApiError>
typealias ChatWebSocketUnreadCountCompletion = ChatWebSocketUnreadCountResult -> Void

protocol ChatDataSource {

    // Event bus reception
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }

    // Messages
    func indexMessages(conversationId: String, numResults: Int, offset: Int, completion: ChatWebSocketMessagesCompletion?)
    func indexMessagesNewerThan(messageId: String, conversationId: String, completion: ChatWebSocketMessagesCompletion?)
    func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int, completion: ChatWebSocketMessagesCompletion?)
    
    // Conversations
    func indexConversations(numResults: Int, offset: Int, filter: WebSocketConversationFilter, completion: ChatWebSocketConversationsCompletion?)
    func showConversation(conversationId: String, completion: ChatWebSocketConversationCompletion?)
    func showConversation(sellerId: String, productId: String, completion: ChatWebSocketConversationCompletion?)

    // Events
    func typingStarted(conversationId: String)
    func typingStopped(conversationId: String)
    
    // Commands
    func sendMessage(conversationId: String, messageId: String, type: String, text: String, completion: ChatWebSocketCommandCompletion?)
    func confirmReception(conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?)
    func confirmRead(conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?)
    func archiveConversations(conversationIds: [String], completion: ChatWebSocketCommandCompletion?)
    func unarchiveConversations(conversationIds: [String], completion: ChatWebSocketCommandCompletion?)

    // Unread messages
    func unreadMessages(userId: String, completion: ChatWebSocketUnreadCountCompletion?)
}
