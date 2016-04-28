//
//  LGChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGChatConversation: ChatConversation {
    let objectId: String?
    let unreadMessageCount: Int
    let lastMessageSentAt: NSDate?
    let product: ChatProduct?
    let interlocutor: ChatInterlocutor?
}

extension LGChatConversation: Decodable {
    
    struct JSONKeys {
        static let objectId = "conversation_id"
        static let unreadMessageCount = "unread_messages_count"
        static let lastMessageSentAt = "last_message_sent_at"
        static let product = "product"
        static let interlocutor = "interlocutor"
    }
    
    static func decode(j: JSON) -> Decoded<LGChatConversation> {
        let init1 = curry(LGChatConversation.init)
            <^> j <|? JSONKeys.objectId
            <*> j <| JSONKeys.unreadMessageCount
            <*> j <|? JSONKeys.lastMessageSentAt
            <*> (j <|? JSONKeys.product >>- LGChatProduct.decodeOptional)
            <*> (j <|? JSONKeys.interlocutor >>- LGChatInterlocutor.decodeOptional)
        return init1
    }
}
