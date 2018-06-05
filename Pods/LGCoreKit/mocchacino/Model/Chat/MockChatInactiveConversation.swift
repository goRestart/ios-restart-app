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
    public var seller: InactiveInterlocutor?
    public var buyer: InactiveInterlocutor?
    public var messages: [ChatInactiveMessage]
    
    public init(objectId: String?,
                lastMessageSentAt: Date?,
                listing: ChatListing?,
                seller: InactiveInterlocutor?,
                buyer: InactiveInterlocutor?,
                messages: [ChatInactiveMessage]) {
        
        self.objectId = objectId
        self.lastMessageSentAt = lastMessageSentAt
        self.listing = listing
        self.seller = seller
        self.buyer = buyer
        self.messages = messages
    }

    public func interlocutor(forMyUserId userId: String?) -> InactiveInterlocutor? {
        guard let myUserId = userId else { return nil }
        if let sellerId = seller?.objectId, sellerId == myUserId {
            return buyer
        } else if let buyerId = buyer?.objectId, buyerId == myUserId {
            return seller
        }
        return nil
    }

    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[CodingKeys.objectId.rawValue] = objectId
        result[CodingKeys.lastMessageSentAt.rawValue] = Int64((lastMessageSentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[CodingKeys.listing.rawValue] = MockChatListing.makeMock().makeDictionary()
        result[CodingKeys.seller.rawValue] = MockInactiveInterlocutor.makeMock().makeDictionary()
        result[CodingKeys.buyer.rawValue] = MockInactiveInterlocutor.makeMock().makeDictionary()
        result[CodingKeys.messages.rawValue] = MockChatInactiveMessage.makeMocks().map { $0.makeDictionary() }
        return result
    }

    enum CodingKeys: String {
        case objectId = "conversation_id"
        case lastMessageSentAt = "last_message_sent_at"
        case listing = "product"
        case seller
        case buyer
        case messages
    }
}

