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

    init(wsStatus: WebSocketStatus) {
        switch wsStatus {
        case .Closed:
            self = .Closed
        case .Closing:
            self = .Closing
        case .Opening:
            self = .Opening
        case .Open(let authStatus):
            switch authStatus {
            case .NotAuthenticated:
                self = .OpenNotAuthenticated
            case .Authenticated:
                self = .OpenAuthenticated
            case .NotVerified:
                self = .OpenNotVerified
            }
        }
    }
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


public class ChatRepository {
    let dataSource: ChatDataSource
    let myUserRepository: MyUserRepository
    public var wsChatStatus = Variable<WSChatStatus>(.Closed)
    let disposeBag = DisposeBag()
    
    public var chatEvents: Observable<ChatEvent> {
        return dataSource.eventBus.asObservable()
    }
    
    init(dataSource: ChatDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
        setupRx()
    }
    
    func setupRx() {
        dataSource.socketStatus.asObservable().subscribeNext { [weak self] status in
            self?.wsChatStatus.value = WSChatStatus(wsStatus: status)
        }.addDisposableTo(disposeBag)

        // Automatically mark as received
        chatEvents.subscribeNext { [weak self] event in
            guard let convId = event.conversationId else { return }
            switch event.type {
            case let .InterlocutorMessageSent(messageId, _, _, _):
                self?.confirmReception(convId, messageIds: [messageId], completion: nil)
            default:
                return
            }
        }.addDisposableTo(disposeBag)
    }
    
    
    // MARK: > Public Methods
    // MARK: - Messages
    
    public func createNewMessage(talkerId: String, text: String, type: ChatMessageType) -> ChatMessage {
        let message = LGChatMessage(objectId: LGUUID().UUIDString, talkerId: talkerId, text: text, sentAt: nil,
                                    receivedAt: nil, readAt: nil, type: type, warnings: [])
        return message
    }
    
    public func indexMessages(conversationId: String, numResults: Int, offset: Int,
                              completion: ChatMessagesCompletion?) {
        dataSource.indexMessages(conversationId, numResults: numResults, offset: offset) { [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
        }
    }
    
    public func indexMessagesNewerThan(messageId: String, conversationId: String, completion: ChatMessagesCompletion?) {
        dataSource.indexMessagesNewerThan(messageId, conversationId: conversationId) { [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
        }
    }
    
    public func indexMessagesOlderThan(messageId: String, conversationId: String, numResults: Int,
                                       completion: ChatMessagesCompletion?) {
        dataSource.indexMessagesOlderThan(messageId, conversationId: conversationId, numResults: numResults) {
            [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
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

    public func sendMessage(conversationId: String, messageId: String, type: ChatMessageType, text: String,
                            completion: ChatCommandCompletion?) {
        dataSource.sendMessage(conversationId, messageId: messageId, type: type.rawValue, text: text) { result in
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

    func confirmReception(conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmReception(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }

    func unarchiveConversations(conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.unarchiveConversations(conversationIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }


    // MARK: - Unread counts

    public func chatUnreadMessagesCount(completion: ChatUnreadMessagesCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ChatUnreadMessagesResult(error: .Internal(message: "Missing myUserId")))
            return
        }
        dataSource.unreadMessages(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    
    // MARK: - Server events
    
    public func chatEventsIn(conversationId: String) -> Observable<ChatEvent> {
        return dataSource.eventBus.filter { $0.conversationId == conversationId }
    }
    
    
    // MARK: - Private

    private func handleQueryMessages(conversationId: String, result: ChatWebSocketMessagesResult,
                                     completion: ChatMessagesCompletion?) {
        var finalResult = result
        if let messages = result.value, myUserId = myUserRepository.myUser?.objectId {
            let receptionIds: [String] = messages.filter { return $0.talkerId != myUserId && $0.receivedAt == nil }
                .flatMap{ $0.objectId }
            if !receptionIds.isEmpty {
                confirmReception(conversationId, messageIds: receptionIds, completion: nil)
                finalResult = ChatWebSocketMessagesResult(messages.map{ $0.markReceived() })
            }
        }
        handleWebSocketResult(finalResult, completion: completion)
    }
}
