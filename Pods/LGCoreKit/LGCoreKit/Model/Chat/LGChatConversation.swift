//
//  LGChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import RxSwift

public protocol ChatConversation: BaseModel {
    var unreadMessageCount: Int { get }
    var lastMessageSentAt: Date? { get }
    var listing: ChatListing? { get }
    var interlocutor: ChatInterlocutor? { get }
    var amISelling: Bool { get }
    var interlocutorIsTyping: Variable<Bool> { get }
    
    init(objectId: String?,
         unreadMessageCount: Int,
         lastMessageSentAt: Date?,
         amISelling: Bool,
         listing: ChatListing?,
         interlocutor: ChatInterlocutor?)
}

extension ChatConversation {
    func updating(interlocutor: ChatInterlocutor?) -> ChatConversation {
        return type(of: self).init(objectId: objectId,
                                   unreadMessageCount: unreadMessageCount,
                                   lastMessageSentAt: lastMessageSentAt,
                                   amISelling: amISelling,
                                   listing: listing,
                                   interlocutor: interlocutor)
    }
    
    func updating(listing: Listing) -> ChatConversation {
        return type(of: self).init(objectId: objectId,
                                   unreadMessageCount: unreadMessageCount,
                                   lastMessageSentAt: lastMessageSentAt,
                                   amISelling: amISelling,
                                   listing: self.listing?.updating(listing: listing),
                                   interlocutor: interlocutor)
    }
    
    func updating(listingStatus: ListingStatus) -> ChatConversation {
        return type(of: self).init(objectId: objectId,
                                   unreadMessageCount: unreadMessageCount,
                                   lastMessageSentAt: lastMessageSentAt,
                                   amISelling: amISelling,
                                   listing: self.listing?.updating(status: listingStatus),
                                   interlocutor: interlocutor)
    }
    
    func updating(unreadMessageCount: Int) -> ChatConversation {
        return type(of: self).init(objectId: objectId,
                                   unreadMessageCount: unreadMessageCount,
                                   lastMessageSentAt: lastMessageSentAt,
                                   amISelling: amISelling,
                                   listing: listing,
                                   interlocutor: interlocutor)
    }
}

struct LGChatConversation: ChatConversation, Decodable {
    let objectId: String?
    let unreadMessageCount: Int
    let lastMessageSentAt: Date?
    let amISelling: Bool
    let listing: ChatListing?
    let interlocutor: ChatInterlocutor?
    let interlocutorIsTyping = Variable<Bool>(false)
    
    init(objectId: String?,
         unreadMessageCount: Int,
         lastMessageSentAt: Date?,
         amISelling: Bool,
         listing: ChatListing?,
         interlocutor: ChatInterlocutor?) {
        
        self.objectId = objectId
        self.unreadMessageCount = unreadMessageCount
        self.lastMessageSentAt = lastMessageSentAt
        self.listing = listing
        self.interlocutor = interlocutor
        self.amISelling = amISelling
    }
    
    fileprivate static func make(objectId: String?,
                                 unreadMessageCount: Int,
                                 lastMessageSentAt: Date?,
                                 amISelling: Bool,
                                 listing: LGChatListing?,
                                 interlocutor: LGChatInterlocutor?) -> LGChatConversation {
        return LGChatConversation(objectId: objectId,
                                  unreadMessageCount: unreadMessageCount,
                                  lastMessageSentAt: lastMessageSentAt,
                                  amISelling: amISelling,
                                  listing: listing,
                                  interlocutor: interlocutor)
    }
    
    // MARK: Decodable
    
    /*
     {
     "conversation_id": [uuid],
     "am_i_selling": [bool],
     "unread_messages_count": [int],
     "last_message_sent_at": [unix_timestamp|null],
     "product": [product|null],
     "interlocutor": [interlocutor|null]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        unreadMessageCount = try keyedContainer.decode(Int.self, forKey: .unreadMessageCount)
        let lastMessageSentAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .lastMessageSentAt)
        lastMessageSentAt = Date.makeChatDate(millisecondsIntervalSince1970: lastMessageSentAtValue)
        amISelling = try keyedContainer.decode(Bool.self, forKey: .amISelling)
        listing = try keyedContainer.decodeIfPresent(LGChatListing.self, forKey: .listing)
        interlocutor = try keyedContainer.decodeIfPresent(LGChatInterlocutor.self, forKey: .interlocutor)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "conversation_id"
        case unreadMessageCount = "unread_messages_count"
        case lastMessageSentAt = "last_message_sent_at"
        case amISelling = "am_i_selling"
        case listing = "product"
        case interlocutor
    }
}
