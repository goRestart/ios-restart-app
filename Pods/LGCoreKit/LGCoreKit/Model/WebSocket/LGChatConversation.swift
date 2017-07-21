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
        let result1 = curry(LGChatConversation.make)
        let result2 = result1 <^> j <|? JSONKeys.objectId
        let result3 = result2 <*> j <| JSONKeys.unreadMessageCount
        let result4 = result3 <*> j <|? JSONKeys.lastMessageSentAt
        let result5 = result4 <*> j <| JSONKeys.amISelling
        let result6 = result5 <*> (j <|? JSONKeys.product >>- LGChatListing.decodeOptional)
        let result  = result6 <*> (j <|? JSONKeys.interlocutor >>- LGChatInterlocutor.decodeOptional)
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGChatConversation parse error: \(error)")
        }
        return result
    }
}
