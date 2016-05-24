//
//  LGChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


import Argo
import Curry

struct LGChatMessage: ChatMessage {
    let objectId: String?
    let talkerId: String
    let text: String
    var sentAt: NSDate?
    var receivedAt: NSDate?
    var readAt: NSDate?
    let type: ChatMessageType
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
    }
    
    static func decode(j: JSON) -> Decoded<LGChatMessage> {
        let init1 = curry(LGChatMessage.init)
            <^> j <|? JSONKeys.objectId
            <*> j <| JSONKeys.talkerId
            <*> j <| JSONKeys.text
            <*> j <|? JSONKeys.sentAt
            <*> j <|? JSONKeys.receivedAt
            <*> j <|? JSONKeys.readAt
            <*> LGArgo.parseChatMessageType(j, key: JSONKeys.type)
        return init1
    }
}

extension LGChatMessage {
    func markAsSent() -> ChatMessage {
        return LGChatMessage(objectId: objectId, talkerId: talkerId, text: text, sentAt: sentAt ?? NSDate(),
                             receivedAt: receivedAt, readAt: readAt, type: type)
    }
    
    func markAsReceived() -> ChatMessage {
        return LGChatMessage(objectId: objectId, talkerId: talkerId, text: text, sentAt: sentAt,
                             receivedAt: receivedAt ?? NSDate(), readAt: readAt, type: type)
    }
    
    func markAsRead() -> ChatMessage {
        return LGChatMessage(objectId: objectId, talkerId: talkerId, text: text, sentAt: sentAt,
                             receivedAt: receivedAt, readAt: readAt ?? NSDate(), type: type)
    }
}
