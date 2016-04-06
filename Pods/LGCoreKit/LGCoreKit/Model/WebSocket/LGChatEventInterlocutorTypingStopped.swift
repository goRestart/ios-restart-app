//
//  LGChatEventInterlocutorTypingStopped.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 31/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry


public struct LGChatEventInterlocutorTypingStopped: ChatEvent {
    public let objectId: String?
    public let type: ChatEventType = .InterlocutorTypingStopped
    public let conversationId: String
}

extension LGChatEventInterlocutorTypingStopped: Decodable {
    public static func decode(j: JSON) -> Decoded<LGChatEventInterlocutorTypingStopped> {
        let init1 = curry(LGChatEventInterlocutorTypingStopped.init)
            <^> j <|? "id"
            <*> j <| ["data", "conversation_id"]
        return init1
    }
}
