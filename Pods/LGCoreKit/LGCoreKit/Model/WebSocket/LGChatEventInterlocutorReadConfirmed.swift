//
//  LGChatEventInterlocutorReadConfirmed.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 31/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGChatEventInterlocutorReadConfirmed: ChatEvent {
    public let objectId: String?
    public let type: ChatEventType = .InterlocutorReadConfirmed
    public let conversationId: String
    
    public let messageIds: [String]
}

extension LGChatEventInterlocutorReadConfirmed: Decodable {
    public static func decode(j: JSON) -> Decoded<LGChatEventInterlocutorReadConfirmed> {
        let init1 = curry(LGChatEventInterlocutorReadConfirmed.init)
            <^> j <|? "id"
            <*> j <|  ["data", "conversation_id"]
            <*> j <|| ["data", "message_ids"]
        return init1
    }
}
