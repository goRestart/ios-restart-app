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
typealias ChatWebSocketMessagesCompletion = (ChatWebSocketMessagesResult) -> Void

typealias ChatWebSocketConversationsResult = Result<[ChatConversation], WebSocketError>
typealias ChatWebSocketConversationsCompletion = (ChatWebSocketConversationsResult) -> Void

typealias ChatWebSocketConversationResult = Result<ChatConversation, WebSocketError>
typealias ChatWebSocketConversationCompletion = (ChatWebSocketConversationResult) -> Void

typealias ChatWebSocketCommandResult = Result<Void, WebSocketError>
typealias ChatWebSocketCommandCompletion = (ChatWebSocketCommandResult) -> Void

typealias ChatWebSocketUnreadCountResult = Result<ChatUnreadMessages, ApiError>
typealias ChatWebSocketUnreadCountCompletion = (ChatWebSocketUnreadCountResult) -> Void

protocol ChatDataSource {

    // Event bus reception
    var eventBus: PublishSubject<ChatEvent> { get }
    var socketStatus: Variable<WebSocketStatus> { get }

    // Messages
    func indexMessages(_ conversationId: String, numResults: Int, offset: Int, completion: ChatWebSocketMessagesCompletion?)
    func indexMessagesNewerThan(_ messageId: String, conversationId: String, completion: ChatWebSocketMessagesCompletion?)
    func indexMessagesOlderThan(_ messageId: String, conversationId: String, numResults: Int, completion: ChatWebSocketMessagesCompletion?)
    
    // Conversations
    func indexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter, completion: ChatWebSocketConversationsCompletion?)
    func showConversation(_ conversationId: String, completion: ChatWebSocketConversationCompletion?)
    func showConversation(_ sellerId: String, productId: String, completion: ChatWebSocketConversationCompletion?)

    // Events
    func typingStarted(_ conversationId: String)
    func typingStopped(_ conversationId: String)
    
    // Commands
    func sendMessage(_ conversationId: String, messageId: String, type: String, text: String, completion: ChatWebSocketCommandCompletion?)
    func confirmReception(_ conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?)
    func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatWebSocketCommandCompletion?)
    func archiveConversations(_ conversationIds: [String], completion: ChatWebSocketCommandCompletion?)
    func unarchiveConversations(_ conversationIds: [String], completion: ChatWebSocketCommandCompletion?)

    // Unread messages
    func unreadMessages(_ userId: String, completion: ChatWebSocketUnreadCountCompletion?)
}
