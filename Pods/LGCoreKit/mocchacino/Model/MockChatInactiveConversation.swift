//
//  MockChatInactiveConversation.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatInactiveConversation: ChatInactiveConversation {
    public var objectId: String?
    public var lastMessageSentAt: Date?
    public var listing: ChatListing?
    public var interlocutor: ChatInterlocutor?
    public var messages: [ChatInactiveMessage]
    
    public init(objectId: String?,
                lastMessageSentAt: Date?,
                listing: ChatListing?,
                interlocutor: ChatInterlocutor?,
                messages: [ChatInactiveMessage]) {
        
        self.objectId = objectId
        self.lastMessageSentAt = lastMessageSentAt
        self.listing = listing
        self.interlocutor = interlocutor
        self.messages = messages
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["conversation_id"] = objectId
        result["last_message_sent_at"] = Int64((lastMessageSentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["product"] = MockChatListing.makeMock().makeDictionary()
        result["interlocutor"] = MockChatInterlocutor.makeMock().makeDictionary()
        result["messages"] = MockChatInactiveMessage.makeMocks().map { $0.makeDictionary() }
        return result
    }
}

