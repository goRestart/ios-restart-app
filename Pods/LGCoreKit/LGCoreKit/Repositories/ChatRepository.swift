//
//  NewChatRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public enum WSChatStatus {
    case closed
    case closing
    case opening
    case openAuthenticated
    case openNotAuthenticated
    case openNotVerified
}

public typealias ChatMessagesResult = Result<[ChatMessage], RepositoryError>
public typealias ChatMessagesCompletion = (ChatMessagesResult) -> Void

public typealias ChatConversationsResult = Result<[ChatConversation], RepositoryError>
public typealias ChatConversationsCompletion = (ChatConversationsResult) -> Void

public typealias ChatConversationResult = Result<ChatConversation, RepositoryError>
public typealias ChatConversationCompletion = (ChatConversationResult) -> Void

public typealias ChatCommandResult = Result<Void, RepositoryError>
public typealias ChatCommandCompletion = (ChatCommandResult) -> Void

public typealias ChatUnreadMessagesResult = Result<ChatUnreadMessages, RepositoryError>
public typealias ChatUnreadMessagesCompletion = (ChatUnreadMessagesResult) -> Void

public protocol ChatRepository {

    var chatStatus: Observable<WSChatStatus> { get }
    var chatEvents: Observable<ChatEvent> { get }


    // MARK: > Public Methods
    // MARK: - Messages

    func createNewMessage(_ talkerId: String, text: String, type: ChatMessageType) -> ChatMessage

    func indexMessages(_ conversationId: String, numResults: Int, offset: Int, completion: ChatMessagesCompletion?)

    func indexMessagesNewerThan(_ messageId: String, conversationId: String, completion: ChatMessagesCompletion?)

    func indexMessagesOlderThan(_ messageId: String, conversationId: String, numResults: Int,
                                       completion: ChatMessagesCompletion?)


    // MARK: - Conversations

    func indexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                                   completion: ChatConversationsCompletion?)

    func showConversation(_ conversationId: String, completion: ChatConversationCompletion?)

    func showConversation(_ sellerId: String, productId: String, completion: ChatConversationCompletion?)


    // MARK: - Events

    func typingStarted(_ conversationId: String)

    func typingStopped(_ conversationId: String)


    // MARK: - Commands

    func sendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                            completion: ChatCommandCompletion?)

    func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)

    func archiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)

    func confirmReception(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)

    func unarchiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)


    // MARK: - Unread counts

    func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?)


    // MARK: - Server events

    func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent>
}
