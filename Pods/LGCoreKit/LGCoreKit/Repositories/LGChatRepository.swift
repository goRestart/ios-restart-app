//
//  LGChatRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

class LGChatRepository: InternalChatRepository {
    
    var chatStatus: Observable<WSChatStatus> {
        return wsChatStatus.asObservable()
    }
    var chatEvents: Observable<ChatEvent> {
        return dataSource.eventBus.asObservable()
    }
    
    let allConversations = CollectionVariable<ChatConversation>([])
    let sellingConversations = CollectionVariable<ChatConversation>([])
    let buyingConversations = CollectionVariable<ChatConversation>([])
    let inactiveConversations = Variable<[ChatInactiveConversation]>([])
    let inactiveConversationsCount = Variable<Int?>(nil)
    let conversationsLock: NSLock = NSLock()
    
    let wsChatStatus = Variable<WSChatStatus>(.closed)
    let dataSource: ChatDataSource
    let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let listingRepository: ListingRepository
    
    private let disposeBag = DisposeBag()
    
    init(dataSource: ChatDataSource,
         myUserRepository: MyUserRepository,
         userRepository: UserRepository,
         listingRepository: ListingRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.listingRepository = listingRepository
        setupRx()
    }
    
    func setupRx() {
        dataSource.socketStatus.asObservable().subscribeNext { [weak self] status in
            self?.wsChatStatus.value = WSChatStatus(wsStatus: status)
            }.disposed(by: disposeBag)
        
        chatStatus.subscribeNext { [weak self] status in
            switch status {
            case .openAuthenticated:
                self?.updateInactiveConversationsCount()
            case .closed, .closing, .opening, .openNotVerified, .openNotAuthenticated:
                break
            }
            }.disposed(by: disposeBag)
        
        // Automatically mark as received
        chatEvents.subscribeNext { [weak self] event in
            guard let conversationId = event.conversationId else { return }
            switch event.type {
            case let .interlocutorMessageSent(messageId, _, _):
                self?.confirmReception(conversationId, messageIds: [messageId]) { _ in
                    self?.updateLocalConversationByFetching(conversationId: conversationId, moveToTop: true)
                }
            case .interlocutorTypingStarted:
                self?.updateLocalConversations(conversationId: conversationId, interlocutorIsTyping: true)
                self?.scheduleInterlocutorIsTypingTimeoutTimer(conversationId: conversationId)
            case .interlocutorTypingStopped:
                self?.cancelInterlocutorIsTypingTimeoutTimer(conversationId: conversationId)
                self?.updateLocalConversations(conversationId: conversationId, interlocutorIsTyping: false)
            default:
                return
            }
            }.disposed(by: disposeBag)
        
        userRepository.events.subscribeNext { [weak self] event in
            switch event {
            case .block(let userId):
                self?.updateLocalConversation(interlocutorId: userId, isBlocked: true)
            case .unblock(let userId):
                self?.updateLocalConversation(interlocutorId: userId, isBlocked: false)
            }
            }.disposed(by: disposeBag)
        
        listingRepository.events.subscribeNext { [weak self] event in
            switch event {
            case .update(let listing):
                self?.updateLocalConversations(listing: listing)
            case .delete(let listingId):
                self?.updateLocalConversations(listingId: listingId, status: .deleted)
            case .sold(let listingId):
                self?.updateLocalConversations(listingId: listingId, status: .sold)
            case .unSold(let listingId):
                self?.updateLocalConversations(listingId: listingId, status: .pending)
            case .create, .favorite, .unFavorite, .createListings:
                break
            }
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Interlocutor is typing local timeout

    private let interlocutorIsTypingTimeoutTime: TimeInterval = 20
    private var interlocutorIsTypingTimeouts: [String:Timer] = [:]
    
    @objc func fireInterlocutorIsTypingTimeout(timer: Timer) {
        guard let conversationId = timer.userInfo as? String else { return }
        updateLocalConversations(conversationId: conversationId, interlocutorIsTyping: false)
    }
    
    private func scheduleInterlocutorIsTypingTimeoutTimer(conversationId: String) {
        cancelInterlocutorIsTypingTimeoutTimer(conversationId: conversationId)
        let newTimer = Timer.scheduledTimer(timeInterval: interlocutorIsTypingTimeoutTime,
                                            target: self,
                                            selector: #selector(fireInterlocutorIsTypingTimeout(timer:)),
                                            userInfo: conversationId,
                                            repeats: false)
        interlocutorIsTypingTimeouts[conversationId] = newTimer
    }
    
    private func cancelInterlocutorIsTypingTimeoutTimer(conversationId: String) {
        interlocutorIsTypingTimeouts[conversationId]?.invalidate()
        interlocutorIsTypingTimeouts.removeValue(forKey: conversationId)
    }
    
    // MARK: > Public Methods
    // MARK: - Messages
    
    func createNewMessage(messageId: String?, talkerId: String, text: String?, type: ChatMessageType) -> ChatMessage {
        return LGChatMessage.make(messageId: messageId, talkerId: talkerId, text: text, type: type)
    }
    
    func indexMessages(_ conversationId: String, numResults: Int, offset: Int,
                       completion: ChatMessagesCompletion?) {
        dataSource.indexMessages(conversationId, numResults: numResults, offset: offset) { [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
        }
    }
    
    func indexMessagesNewerThan(_ messageId: String, conversationId: String, completion: ChatMessagesCompletion?) {
        dataSource.indexMessagesNewerThan(messageId, conversationId: conversationId) { [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
        }
    }
    
    func indexMessagesOlderThan(_ messageId: String, conversationId: String, numResults: Int,
                                completion: ChatMessagesCompletion?) {
        dataSource.indexMessagesOlderThan(messageId, conversationId: conversationId, numResults: numResults) {
            [weak self] result in
            self?.handleQueryMessages(conversationId, result: result, completion: completion)
        }
    }
    
    
    // MARK: - Conversations
    
    func internalIndexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                                    completion: ChatConversationsCompletion?) {
        dataSource.indexConversations(numResults, offset: offset, filter: filter) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func showConversation(_ conversationId: String, completion: ChatConversationCompletion?) {
        dataSource.showConversation(conversationId) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func showConversation(_ sellerId: String, listingId: String, completion: ChatConversationCompletion?) {
        dataSource.showConversation(sellerId, listingId: listingId) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func fetchInactiveConversationsCount(completion: ChatCountCompletion?) {
        dataSource.fetchInactiveConversationsCount { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func fetchInactiveConversations(limit: Int, offset: Int, completion: ChatInactiveConversationsCompletion?) {
        dataSource.fetchInactiveConversations(limit: limit, offset: offset) { [weak self] result in
            guard let strongSelf = self else { return }
            if let inactiveConversations = result.value {
                let isFirstPage = offset == 0
                if isFirstPage {
                    strongSelf.inactiveConversations.value = inactiveConversations
                } else {
                    strongSelf.inactiveConversations.value = strongSelf.inactiveConversations.value + inactiveConversations
                }
            }
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    
    // MARK: - Events
    
    func typingStarted(_ conversationId: String) {
        dataSource.typingStarted(conversationId)
    }
    
    func typingStopped(_ conversationId: String) {
        dataSource.typingStopped(conversationId)
    }
    
    
    // MARK: - Commands
    
    func internalSendMessage(_ conversationId: String,
                             messageId: String,
                             type: WebSocketSendMessageType,
                             text: String,
                             answerKey: String?,
                             completion: ChatCommandCompletion?) {
        dataSource.sendMessage(conversationId, messageId: messageId, type: type, text: text, answerKey: answerKey) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func internalConfirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmRead(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func internalArchiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.archiveConversations(conversationIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func internalArchiveInactiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.archiveInactiveConversations(conversationIds) { [weak self] result in
            if let _ = result.value, let inactiveConversationsCount = self?.inactiveConversationsCount.value {
                self?.inactiveConversationsCount.value = inactiveConversationsCount - conversationIds.count
            }
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func confirmReception(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmReception(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func internalUnarchiveConversation(_ conversationId: String, completion: ChatCommandCompletion?) {
        dataSource.unarchiveConversations([conversationId]) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    func internalMarkAllConversationsAsRead(completion: ChatCommandCompletion?) {
        dataSource.markAllConversationsAsRead { result in
            handleWebSocketResult(result, completion: completion)
        }
    }
    
    
    // MARK: - Unread counts
    
    func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(ChatUnreadMessagesResult(error: .internalError(message: "Missing myUserId")))
            return
        }
        dataSource.unreadMessages(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    // MARK: - Clean
    
    func cleanInactiveConversations() {
        inactiveConversations.value.removeAll()
    }
    
    func clean() {
        cleanInactiveConversations()
    }
    
    
    // MARK: - Server events
    
    func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent> {
        return dataSource.eventBus.filter { $0.conversationId == conversationId }
    }
    
    // MARK: - Private
    
    private func handleQueryMessages(_ conversationId: String, result: ChatWebSocketMessagesResult,
                                     completion: ChatMessagesCompletion?) {
        var finalResult = result
        if let messages = result.value, let myUserId = myUserRepository.myUser?.objectId {
            let receptionIds: [String] = messages.filter { return $0.talkerId != myUserId && $0.receivedAt == nil }
                .compactMap{ $0.objectId }
            if !receptionIds.isEmpty {
                confirmReception(conversationId, messageIds: receptionIds, completion: nil)
                finalResult = ChatWebSocketMessagesResult(messages.map{ $0.markReceived() })
            }
        }
        handleWebSocketResult(finalResult, completion: completion)
    }
    
    private func updateInactiveConversationsCount() {
        fetchInactiveConversationsCount { [weak self] result in
            if let count = result.value {
                self?.inactiveConversationsCount.value = count
            }
        }
    }
}


// MARK: - WSChatStatus extension

extension WSChatStatus {
    init(wsStatus: WebSocketStatus) {
        switch wsStatus {
        case .closed:
            self = .closed
        case .closing:
            self = .closing
        case .opening:
            self = .opening
        case .open(let authStatus):
            switch authStatus {
            case .notAuthenticated:
                self = .openNotAuthenticated
            case .authenticated:
                self = .openAuthenticated
            case .notVerified:
                self = .openNotVerified
            }
        }
    }
}

