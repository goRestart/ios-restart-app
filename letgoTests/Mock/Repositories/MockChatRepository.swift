//
//  MockChatRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class MockChatRepository: ChatRepository {

    var chatStatus: Observable<WSChatStatus> {
        return chatStatusVariable.asObservable()
    }
    var chatEvents: Observable<ChatEvent> {
        return chatEventsSignal.asObservable()
    }

    var chatStatusVariable = Variable<WSChatStatus>(.closed)
    var chatEventsSignal = PublishSubject<ChatEvent>()

    var chatMessagesResult: ChatMessagesResult?
    var chatConversationsResult: ChatConversationsResult?
    var chatConversationResult: ChatConversationResult?
    var chatCommandResult: ChatCommandResult?
    var chatUnreadMessagesResult: ChatUnreadMessagesResult?

    // MARK: > Public Methods
    // MARK: - Messages

    func createNewMessage(_ talkerId: String, text: String, type: ChatMessageType) -> ChatMessage {
        var result = MockChatMessage()
        result.talkerId = talkerId
        result.text = text
        result.type = type
        return result
    }

    func indexMessages(_ conversationId: String, numResults: Int, offset: Int, completion: ChatMessagesCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatMessagesResult)
    }

    func indexMessagesNewerThan(_ messageId: String, conversationId: String, completion: ChatMessagesCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatMessagesResult)
    }

    func indexMessagesOlderThan(_ messageId: String, conversationId: String, numResults: Int,
                                completion: ChatMessagesCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatMessagesResult)
    }


    // MARK: - Conversations

    func indexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                            completion: ChatConversationsCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatConversationsResult)

    }

    func showConversation(_ conversationId: String, completion: ChatConversationCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatConversationResult)
    }

    func showConversation(_ sellerId: String, productId: String, completion: ChatConversationCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatConversationResult)
    }


    // MARK: - Events

    func typingStarted(_ conversationId: String) {}

    func typingStopped(_ conversationId: String) {}


    // MARK: - Commands

    func sendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                     completion: ChatCommandCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatCommandResult)
    }

    func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatCommandResult)
    }

    func archiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatCommandResult)
    }

    func confirmReception(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatCommandResult)
    }

    func unarchiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatCommandResult)
    }


    // MARK: - Unread counts

    func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?) {
        performAfterDelayWithCompletion(completion, result: chatUnreadMessagesResult)
    }


    // MARK: - Server events
    
    func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent> {
        return chatEventsSignal.asObservable()
    }
}
