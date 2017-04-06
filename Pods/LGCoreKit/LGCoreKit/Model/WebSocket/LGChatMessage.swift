//
//  LGChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatMessage: ChatMessage {
    let objectId: String?
    let talkerId: String
    let text: String
    var sentAt: Date?
    var receivedAt: Date?
    var readAt: Date?
    let type: ChatMessageType
    var warnings: [ChatMessageWarning]

    func markReceived() -> ChatMessage {
        return LGChatMessage(objectId: objectId, talkerId: talkerId, text: text, sentAt: sentAt,
                             receivedAt: receivedAt ?? Date(), readAt: readAt, type: type, warnings: warnings)
    }
}

extension LGChatMessage: Decodable {
    
    struct JSONKeys {
        static let objectId = "message_id"
        static let talkerId = "talker_id"
        static let text = "text"
        static let sentAt = "sent_at"
        static let receivedAt = "received_at"
        static let readAt = "read_at"
        static let type = "type"
        static let warnings = "warnings"
    }
    
    static func decode(_ j: JSON) -> Decoded<LGChatMessage> {
        let init1 = curry(LGChatMessage.init)
            <^> j <|? JSONKeys.objectId
            <*> j <| JSONKeys.talkerId
            <*> j <| JSONKeys.text
            <*> j <|? JSONKeys.sentAt
            <*> j <|? JSONKeys.receivedAt
            <*> j <|? JSONKeys.readAt
            <*> LGArgo.parseChatMessageType(j, key: [JSONKeys.type])
            <*> j <|| JSONKeys.warnings

        if let error = init1.error {
            logMessage(.error, type: .parsing, message: "LGChatListing parse error: \(error)")
        }
        return init1
    }
}
