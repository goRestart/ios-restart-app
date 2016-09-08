//
//  NewChatRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift
import ReachabilitySwift

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
    let webSocketClient: WebSocketClient
    let reachability: Reachability?
    public var chatAvailable = Variable<Bool>(false)
    let disposeBag = DisposeBag()
    
    public var chatEvents: Observable<ChatEvent> {
        return webSocketClient.eventBus.asObservable()
    }
    
    init(dataSource: ChatDataSource, myUserRepository: MyUserRepository, webSocketClient: WebSocketClient) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
        self.webSocketClient = webSocketClient
        self.reachability = try? Reachability.reachabilityForInternetConnection()
        configureReachability()
        setupRx()
    }
    
    func setupRx() {
        webSocketClient.socketStatus.asObservable().subscribeNext { [weak self] status in
            switch status {
            case .Open(let authenticated) where authenticated:
                self?.chatAvailable.value = true
            default:
                self?.chatAvailable.value = false
            }
            }.addDisposableTo(disposeBag)
    }
    
    
    // MARK: > Public Methods
    // MARK: - Messages
    
    public func openAndAuthenticate(completion: (Result<Void, SessionManagerError> -> ())?) {
        guard LGCoreKit.activateWebsocket && InternalCore.sessionManager.loggedIn else {
            completion?(Result<Void, SessionManagerError>(error: .Unauthorized))
            return
        }
        webSocketClient.startWebSocket(EnvironmentProxy.sharedInstance.webSocketURL) {
            InternalCore.sessionManager.authenticateWebSocket(completion)
        }
    }
    
    public func close(completion: (() -> ())?) {
        webSocketClient.closeWebSocket(completion)
    }
    
    public func createNewMessage(talkerId: String, text: String, type: ChatMessageType) -> ChatMessage {
        let message = LGChatMessage(objectId: LGUUID().UUIDString, talkerId: talkerId, text: text, sentAt: nil,
                                    receivedAt: nil, readAt: nil, type: type, warnings: [])
        return message
    }
    
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
        return webSocketClient.eventBus.filter { $0.conversationId == conversationId }
    }
    
    
    // MARK: - Private
    
    private func configureReachability() {
        reachability?.whenReachable = { [weak self] _ in
            self?.openAndAuthenticate(nil)
        }
        do {
            try reachability?.startNotifier()
        } catch {}
    }
}
