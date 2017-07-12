//
//  LGChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatConversation: ChatConversation {
    let objectId: String?
    let unreadMessageCount: Int
    let lastMessageSentAt: Date?
    let amISelling: Bool
    let listing: ChatListing?
    let interlocutor: ChatInterlocutor?
    
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
}

extension LGChatConversation: Decodable {
    
    struct JSONKeys {
        static let objectId = "conversation_id"
        static let unreadMessageCount = "unread_messages_count"
        static let lastMessageSentAt = "last_message_sent_at"
        static let product = "product"
        static let interlocutor = "interlocutor"
        static let amISelling = "am_i_selling"
    }
    
    static func decode(_ j: JSON) -> Decoded<LGChatConversation> {
        let init1 = curry(LGChatConversation.init)
            <^> j <|? JSONKeys.objectId
            <*> j <| JSONKeys.unreadMessageCount
            <*> j <|? JSONKeys.lastMessageSentAt
            <*> j <| JSONKeys.amISelling
            <*> (j <|? JSONKeys.product >>- LGChatListing.decodeOptional)
            <*> (j <|? JSONKeys.interlocutor >>- LGChatInterlocutor.decodeOptional)

        if let error = init1.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGChatConversation parse error: \(error)")
        }
        return init1
    }
}
