//
//  LGChatUnreadMessages.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatUnreadMessages: ChatUnreadMessages {
    let totalUnreadMessages: Int
    let unreadConversations: [ConversationUnreadMessages]

    init(totalUnreadMessages: Int, unreadConversations: [LGConversationUnreadMessages]) {
        self.totalUnreadMessages = totalUnreadMessages
        self.unreadConversations = unreadConversations.map{ $0 }
    }
}

struct LGConversationUnreadMessages: ConversationUnreadMessages {
    let conversationId: String
    let unreadMessages: Int
}

extension LGChatUnreadMessages : Decodable {

    /**
     Expects a json in the form:
     {
     "total_unread_messages_count": 2,
     "unread_conversations": [ LGConversationUnreadMessages array ]
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGChatUnreadMessages> {

        let result = curry(LGChatUnreadMessages.init)
            <^> j <| "total_unread_messages_count"
            <*> j <|| "unread_conversations"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGChatUnreadMessages parse error: \(error)")
        }

        return result
    }
}

extension LGConversationUnreadMessages : Decodable {

    /**
     Expects a json in the form:
     {
     "conversation_id": "349857098xc98we7",
     "unread_messages_count": 4
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGConversationUnreadMessages> {

        let result = curry(LGConversationUnreadMessages.init)
            <^> j <| "conversation_id"
            <*> j <| "unread_messages_count"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGConversationUnreadMessages parse error: \(error)")
        }

        return result
    }
}

