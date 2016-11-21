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
    case Closed
    case Closing
    case Opening
    case OpenAuthenticated
    case OpenNotAuthenticated
    case OpenNotVerified
}

public typealias ChatMessagesResult = Result<[ChatMessage], RepositoryError>
public typealias ChatMessagesCompletion = ChatMessagesResult -> Void

public typealias ChatConversationsResult = Result<[ChatConversation], RepositoryError>
public typealias ChatConversationsCompletion = ChatConversationsResult -> Void

public typealias ChatConversationResult = Result<ChatConversation, RepositoryError>
public typealias ChatConversationCompletion = ChatConversationResult -> Void

public typealias ChatCommandResult = Result<Void, RepositoryError>
public typealias ChatCommandCompletion = ChatCommandResult -> Void

public typealias ChatUnreadMessagesResult = Result<ChatUnreadMessages, RepositoryError>
public typealias ChatUnreadMessagesCompletion = ChatUnreadMessagesResult -> Void

public protocol ChatRepository {

    var chatStatus: Observable<WSChatStatus> { get }
    var chatEvents: Observable<ChatEvent> { get }


    // MARK: > Public Methods
    // MARK: - Messages

    func createNewMessage(talkerId: String, text: String, type: ChatMessageType) -> ChatMessage

    func indexMessages(conversationId: String, numResults: Int, offset: Int, completion: ChatMessagesCompletion?)

    func indexMessagesNewerThan(messageId: String, conversationId: String, completion: ChatMessagesCompletion?)

    func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int,
                                       completion: ChatMessagesCompletion?)


    // MARK: - Conversations

    func indexConversations(numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                                   completion: ChatConversationsCompletion?)

    func showConversation(conversationId: String, completion: ChatConversationCompletion?)

    func showConversation(sellerId: String, productId: String, completion: ChatConversationCompletion?)


    // MARK: - Events

    func typingStarted(conversationId: String)

    func typingStopped(conversationId: String)


    // MARK: - Commands

    func sendMessage(conversationId: String, messageId: String, type: ChatMessageType, text: String,
                            completion: ChatCommandCompletion?)

    func confirmRead(conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)

    func archiveConversations(conversationIds: [String], completion: ChatCommandCompletion?)

    func confirmReception(conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)

    func unarchiveConversations(conversationIds: [String], completion: ChatCommandCompletion?)


    // MARK: - Unread counts

    func chatUnreadMessagesCount(completion: ChatUnreadMessagesCompletion?)


    // MARK: - Server events

    func chatEventsIn(conversationId: String) -> Observable<ChatEvent>
}
