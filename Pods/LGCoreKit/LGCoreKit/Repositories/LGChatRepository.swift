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
        }.addDisposableTo(disposeBag)

        // Automatically mark as received
        chatEvents.subscribeNext { [weak self] event in
            guard let conversationId = event.conversationId else { return }
            switch event.type {
            case let .interlocutorMessageSent(messageId, _, _, _):
                self?.confirmReception(conversationId, messageIds: [messageId]) { _ in
                    self?.updateLocalConversationByFetching(conversationId: conversationId, moveToTop: true)
                }
            default:
                return
            }
        }.addDisposableTo(disposeBag)
        
        userRepository.events.subscribeNext { [weak self] event in
            switch event {
            case .block(let userId):
                self?.updateLocalConversation(interlocutorId: userId, isBlocked: true)
            case .unblock(let userId):
                self?.updateLocalConversation(interlocutorId: userId, isBlocked: false)
            }
        }.addDisposableTo(disposeBag)
        
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
            case .create, .favorite, .unFavorite:
                break
            }
        }.addDisposableTo(disposeBag)
    }
    

    // MARK: > Public Methods
    // MARK: - Messages

    func createNewMessage(_ talkerId: String, text: String, type: ChatMessageType) -> ChatMessage {
        let message = LGChatMessage(objectId: LGUUID().UUIDString, talkerId: talkerId, text: text, sentAt: nil,
                                    receivedAt: nil, readAt: nil, type: type, warnings: [])
        return message
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

    func showConversation(_ sellerId: String, productId: String, completion: ChatConversationCompletion?) {
        dataSource.showConversation(sellerId, productId: productId) { result in
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

    func internalSendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                             completion: ChatCommandCompletion?) {
        dataSource.sendMessage(conversationId, messageId: messageId, type: type.rawValue, text: text) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }

    func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        dataSource.confirmRead(conversationId, messageIds: messageIds) { result in
            handleWebSocketResult(result, completion: completion)
        }
    }

    func internalArchiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        dataSource.archiveConversations(conversationIds) { result in
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
                .flatMap{ $0.objectId }
            if !receptionIds.isEmpty {
                confirmReception(conversationId, messageIds: receptionIds, completion: nil)
                finalResult = ChatWebSocketMessagesResult(messages.map{ $0.markReceived() })
            }
        }
        handleWebSocketResult(finalResult, completion: completion)
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
