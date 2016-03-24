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
    var objectId: String?
    var talkerId: String
    var text: String
    var sentAt: NSDate?
    var receivedAt: NSDate?
    var readAt: NSDate?
    var type: String
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
            <*> LGArgo.parseDate(json: j, key: "sent_at")
            <*> LGArgo.parseDate(json: j, key: "received_at")
            <*> LGArgo.parseDate(json: j, key: "read_at")
            <*> j <| JSONKeys.type
        
        return init1
    }
}
