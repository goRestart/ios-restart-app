//
//  ChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatConversation: BaseModel {
    var unreadMessageCount: Int { get }
    var lastMessageSentAt: Date? { get }
    var listing: ChatListing? { get }
    var interlocutor: ChatInterlocutor? { get }
    var amISelling: Bool { get }

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
}
