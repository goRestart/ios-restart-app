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
    let sentAt: NSDate?
    let receivedAt: NSDate?
    let readAt: NSDate?
    let type: ChatMessageType
}

extension LGChatMessage: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
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
