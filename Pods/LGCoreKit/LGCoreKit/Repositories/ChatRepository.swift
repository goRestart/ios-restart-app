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

public typealias ChatInactiveConversationsResult = Result<[ChatInactiveConversation], RepositoryError>
public typealias ChatInactiveConversationsCompletion = (ChatInactiveConversationsResult) -> Void

public typealias ChatCountResult = Result<Int, RepositoryError>
public typealias ChatCountCompletion = (ChatCountResult) -> Void

public typealias ChatCommandResult = Result<Void, RepositoryError>
public typealias ChatCommandCompletion = (ChatCommandResult) -> Void

public typealias ChatUnreadMessagesResult = Result<ChatUnreadMessages, RepositoryError>
public typealias ChatUnreadMessagesCompletion = (ChatUnreadMessagesResult) -> Void


// MARK: - ChatRepository

public protocol ChatRepository: class {
    var chatStatus: Observable<WSChatStatus> { get }
    var chatEvents: Observable<ChatEvent> { get }
    var allConversations: CollectionVariable<ChatConversation> { get }
    var sellingConversations: CollectionVariable<ChatConversation> { get }
    var buyingConversations: CollectionVariable<ChatConversation> { get }
    var inactiveConversations: Variable<[ChatInactiveConversation]> { get }
    var inactiveConversationsCount: Variable<Int?> { get }
    var conversationsLock: NSLock { get }
    
    // MARK: > Messages
    
    func createNewMessage(_ talkerId: String, text: String, type: ChatMessageType) -> ChatMessage
    func indexMessages(_ conversationId: String, numResults: Int, offset: Int, completion: ChatMessagesCompletion?)
    func indexMessagesNewerThan(_ messageId: String, conversationId: String, completion: ChatMessagesCompletion?)
    func indexMessagesOlderThan(_ messageId: String, conversationId: String, numResults: Int,
                                completion: ChatMessagesCompletion?)
    
    // MARK: > Conversations
    
    func indexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                            completion: ChatConversationsCompletion?)
    func showConversation(_ conversationId: String, completion: ChatConversationCompletion?)
    func showConversation(_ sellerId: String, listingId: String, completion: ChatConversationCompletion?)
    func fetchInactiveConversationsCount(completion: ChatCountCompletion?)
    func fetchInactiveConversations(limit: Int, offset: Int, completion: ChatInactiveConversationsCompletion?)
    
    // MARK: > Events
    
    func typingStarted(_ conversationId: String)
    func typingStopped(_ conversationId: String)
    
    // MARK: > Commands
    
    func sendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                     completion: ChatCommandCompletion?)
    func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)
    func archiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)
    func archiveInactiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)
    func confirmReception(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)
    func unarchiveConversation(_ conversationId: String, completion: ChatCommandCompletion?)
    
    // MARK: > Unread counts
    
    func chatUnreadMessagesCount(_ completion: ChatUnreadMessagesCompletion?)
    
    // MARK: > Server events
    
    func chatEventsIn(_ conversationId: String) -> Observable<ChatEvent>
    
    // MARK: > Cleaning
    
    func cleanInactiveConversations()
    func clean()
}


// MARK: - InternalChatRepository

protocol InternalChatRepository: ChatRepository {
    func internalIndexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                                    completion: ChatConversationsCompletion?)
    func updateLocalConversationByFetching(conversationId: String, moveToTop: Bool)
    func updateLocalConversations(listing: Listing)
    func updateLocalConversations(listingId: String, status: ListingStatus)
    func insertLocalConversationByFetching(conversationId: String)
    func removeLocalConversation(id: String)
    func removeLocalConversations(ids: [String])
    
    func internalSendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                             completion: ChatCommandCompletion?)
    func internalConfirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?)
    func internalArchiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)
    func internalArchiveInactiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?)
    func internalUnarchiveConversation(_ conversationId: String, completion: ChatCommandCompletion?)
}

extension InternalChatRepository {
    public func indexConversations(_ numResults: Int, offset: Int, filter: WebSocketConversationFilter,
                                   completion: ChatConversationsCompletion?) {
        internalIndexConversations(numResults, offset: offset, filter: filter) { [weak self] result in
            defer { completion?(result) }
            guard let strongSelf = self,
                let newConversations = result.value else { return }
            
            let conversationsCollectionVariable: CollectionVariable<ChatConversation>?
            switch filter {
            case .all:
                conversationsCollectionVariable = strongSelf.allConversations
            case .archived:
                conversationsCollectionVariable = nil
            case .asBuyer:
                conversationsCollectionVariable = strongSelf.buyingConversations
            case .asSeller:
                conversationsCollectionVariable = strongSelf.sellingConversations
            }
            guard let conversations = conversationsCollectionVariable else { return }
            
            let isFirstPage = offset == 0
            if isFirstPage {
                if conversations.value.isEmpty {
                    conversations.appendContentsOf(newConversations)
                } else {
                    conversations.replace(0..<conversations.value.count,
                                          with: newConversations)
                }
            } else {
                conversations.appendContentsOf(newConversations)
            }
        }
    }
    
    public func updateLocalConversationByFetching(conversationId: String, moveToTop: Bool) {
        showConversation(conversationId) { [weak self] result in
            guard let updatedConversation = result.value else { return }
            self?.updateLocalConversation(updatedConversation: updatedConversation, moveToTop: moveToTop)
        }
    }
    
    public func updateLocalConversations(listing: Listing) {
        updateLocalConversations(listingId: listing.objectId) { conversation in
            return conversation.updating(listing: listing)
        }
    }
    
    public func updateLocalConversations(listingId: String, status: ListingStatus) {
        updateLocalConversations(listingId: listingId) { conversation in
            return conversation.updating(listingStatus: status)
        }
    }
    
    public func updateLocalConversation(interlocutorId: String, isBlocked: Bool) {
        let filterByInterlocutorId: ((index: Int, conversation: ChatConversation)) -> Bool = {
            $0.conversation.interlocutor?.objectId == interlocutorId
        }
        updateLocalConversations(filterQuery: filterByInterlocutorId) { conversation in
            guard let interlocutor = conversation.interlocutor else { return nil }
            let updatedInterlocutor = interlocutor.updating(isMuted: isBlocked)
            return conversation.updating(interlocutor: updatedInterlocutor)
        }
    }
    
    private func updateLocalConversations(listingId: String?,
                                          updatingConversation: (ChatConversation) -> ChatConversation?) {
        let filterByListingId: ((index: Int, conversation: ChatConversation)) -> Bool = {
            $0.conversation.listing?.objectId == listingId
        }
        updateLocalConversations(filterQuery: filterByListingId, updatingConversation: updatingConversation)
    }
    
    private func updateLocalConversations(filterQuery: ((index: Int, conversation: ChatConversation)) -> Bool,
                                          updatingConversation: (ChatConversation) -> ChatConversation?) {
        let conversationsArrays = [allConversations, buyingConversations, sellingConversations]
        conversationsArrays.forEach { conversations in
            conversations.value.enumerated().filter(filterQuery).forEach { (index, conversation) in
                guard let updatedConversation = updatingConversation(conversation) else { return }
                conversations.replace(index, with: updatedConversation)
            }
        }
    }
    
    private func updateLocalConversation(updatedConversation: ChatConversation, moveToTop: Bool) {
        let conversationsArrays: [CollectionVariable<ChatConversation>]
        if updatedConversation.amISelling {
            conversationsArrays = [allConversations, sellingConversations]
        } else {
            conversationsArrays = [allConversations, buyingConversations]
        }
        conversationsArrays.forEach { conversations in
            let insertIndex: Int?
            let removeIndex = conversations.value.index(where: { $0.objectId == updatedConversation.objectId })
            if let removeIndex = removeIndex {
                insertIndex = moveToTop ? 0 : removeIndex
            } else if moveToTop {
                insertIndex = 0
            } else {
                insertIndex = nil
            }
            
            if let insertIndex = insertIndex, let removeIndex = removeIndex {
                if insertIndex == removeIndex {
                    conversations.replace(insertIndex, with: updatedConversation)
                } else {
                    conversations.move(fromIndex: removeIndex, toIndex: insertIndex, replacingWith: updatedConversation)
                }
            } else if let insertIndex = insertIndex {
                conversations.insert(updatedConversation, atIndex: insertIndex)
            } else if let removeIndex = removeIndex {
                conversations.removeAtIndex(removeIndex)
            }
        }
    }
    
    public func insertLocalConversationByFetching(conversationId: String) {
        showConversation(conversationId) { [weak self] result in
            guard let strongSelf = self,
                let updatedConversation = result.value,
                let updatedlastMessageSentAt = updatedConversation.lastMessageSentAt else { return }
            
            strongSelf.conversationsLock.lock()
            
            // Remove if was in place before & ordered (by date) insert
            let findById: (ChatConversation) -> Bool = { $0.objectId == conversationId }
            let findPositionByDate: (ChatConversation) -> Bool = { conversation in
                guard let lDate = conversation.lastMessageSentAt else { return true }
                return lDate.compare(updatedlastMessageSentAt) == .orderedAscending
            }
            
            if let index = strongSelf.allConversations.value.index(where: findById) {
                strongSelf.allConversations.replace(index, with: updatedConversation)
            } else if let index = strongSelf.allConversations.value.index(where: findPositionByDate) {
                strongSelf.allConversations.insert(updatedConversation, atIndex: index)
            } else {
                strongSelf.allConversations.append(updatedConversation)
            }
            
            if updatedConversation.amISelling {
                if let index = strongSelf.sellingConversations.value.index(where: findById) {
                    strongSelf.sellingConversations.replace(index, with: updatedConversation)
                } else if let index = strongSelf.sellingConversations.value.index(where: findPositionByDate) {
                    strongSelf.sellingConversations.insert(updatedConversation, atIndex: index)
                } else {
                    strongSelf.sellingConversations.append(updatedConversation)
                }
            } else {
                if let index = strongSelf.buyingConversations.value.index(where: findById) {
                    strongSelf.buyingConversations.replace(index, with: updatedConversation)
                } else if let index = strongSelf.buyingConversations.value.index(where: findPositionByDate) {
                    strongSelf.buyingConversations.insert(updatedConversation, atIndex: index)
                } else {
                    strongSelf.buyingConversations.append(updatedConversation)
                }
            }
            
            strongSelf.conversationsLock.unlock()
        }
    }
    
    public func removeLocalConversation(id: String) {
        conversationsLock.lock()
        if let index = allConversations.value.index(where: { $0.objectId == id }) {
            allConversations.removeAtIndex(index)
        }
        if let index = sellingConversations.value.index(where: { $0.objectId == id }) {
            sellingConversations.removeAtIndex(index)
        }
        if let index = buyingConversations.value.index(where: { $0.objectId == id }) {
            buyingConversations.removeAtIndex(index)
        }
        if let index = inactiveConversations.value.index(where: { $0.objectId == id }) {
            inactiveConversations.value.remove(at: index)
        }
        conversationsLock.unlock()
    }
    
    public func removeLocalConversations(ids: [String]) {
        ids.forEach { removeLocalConversation(id: $0) }
    }
    
    public func sendMessage(_ conversationId: String, messageId: String, type: ChatMessageType, text: String,
                            completion: ChatCommandCompletion?) {
        internalSendMessage(conversationId, messageId: messageId, type: type, text: text) { [weak self] sendMessageResult in
            defer {
                completion?(sendMessageResult)
            }
            guard let _ = sendMessageResult.value else { return }
            
            self?.updateLocalConversationByFetching(conversationId: conversationId, moveToTop: true)
        }
    }
    
    public func confirmRead(_ conversationId: String, messageIds: [String], completion: ChatCommandCompletion?) {
        internalConfirmRead(conversationId, messageIds: messageIds) { [weak self] confirmReadResult in
            defer {
                completion?(confirmReadResult)
            }
            guard let _ = confirmReadResult.value else { return }
            
            self?.updateLocalConversationByFetching(conversationId: conversationId, moveToTop: false)
        }
    }
    
    
    public func archiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        internalArchiveConversations(conversationIds) { [weak self] archiveResult in
            defer { completion?(archiveResult) }
            self?.removeLocalConversations(ids: conversationIds)
        }
    }
    
    public func archiveInactiveConversations(_ conversationIds: [String], completion: ChatCommandCompletion?) {
        internalArchiveInactiveConversations(conversationIds) { [weak self] archiveResult in
            defer { completion?(archiveResult) }
            self?.removeLocalConversations(ids: conversationIds)
        }
    }
    
    public func unarchiveConversation(_ conversationId: String, completion: ChatCommandCompletion?) {
        internalUnarchiveConversation(conversationId) { [weak self] unarchiveResult in
            defer { completion?(unarchiveResult) }
            self?.insertLocalConversationByFetching(conversationId: conversationId)
        }
    }
}

