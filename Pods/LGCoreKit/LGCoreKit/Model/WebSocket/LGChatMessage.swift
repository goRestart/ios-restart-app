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
        let result1 = curry(LGChatMessage.init)
        let result2 = result1 <^> j <|? JSONKeys.objectId
        let result3 = result2 <*> j <| JSONKeys.talkerId
        let result4 = result3 <*> j <| JSONKeys.text
        let result5 = result4 <*> j <|? JSONKeys.sentAt
        let result6 = result5 <*> j <|? JSONKeys.receivedAt
        let result7 = result6 <*> j <|? JSONKeys.readAt
        let result8 = result7 <*> LGArgo.parseChatMessageType(j, key: [JSONKeys.type])
        let result  = result8 <*> j <|| JSONKeys.warnings
        if let error = result.error {
            logMessage(.error, type: .parsing, message: "LGChatMessage parse error: \(error)")
        }
        return result
    }
}
