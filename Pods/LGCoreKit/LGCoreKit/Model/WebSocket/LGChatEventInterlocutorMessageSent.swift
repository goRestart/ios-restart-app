//
//  LGChatEventInterlocutorMessageSent.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 31/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry


public struct LGChatEventInterlocutorMessageSent: ChatEvent {
    public let objectId: String?
    public let type: ChatEventType = .InterlocutorMessageSent
    public let conversationId: String
    
    public let messageId: String
    public let sentAt: NSDate?
    public let text: String
}


extension LGChatEventInterlocutorMessageSent: Decodable {
    public static func decode(j: JSON) -> Decoded<LGChatEventInterlocutorMessageSent> {
        let init1 = curry(LGChatEventInterlocutorMessageSent.init)
            <^> j <|? "id"
            <*> j <| ["data", "conversation_id"]
            <*> j <| ["data", "message_id"]
            <*> LGArgo.parseTimeStampInMs(json: j, key: ["data", "sent_at"])
            <*> j <| ["data", "text"]
        return init1
    }
}
