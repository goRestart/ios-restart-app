//
//  LGChatEventInterlocutorTypingStarted.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 31/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry


public struct LGChatEventInterlocutorTypingStarted: ChatEvent {
    public let objectId: String?
    public let type: ChatEventType = .InterlocutorTypingStarted
    public let conversationId: String
}

extension LGChatEventInterlocutorTypingStarted: Decodable {
    public static func decode(j: JSON) -> Decoded<LGChatEventInterlocutorTypingStarted> {
        let init1 = curry(LGChatEventInterlocutorTypingStarted.init)
            <^> j <|? "id"
            <*> j <| ["data", "conversation_id"]
        return init1
    }
}
