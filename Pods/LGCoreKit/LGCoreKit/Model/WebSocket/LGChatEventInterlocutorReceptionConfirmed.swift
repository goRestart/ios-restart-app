//
//  LGChatEventInterlocutorReceptionConfirmed.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 31/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry


public struct LGChatEventInterlocutorReceptionConfirmed: ChatEvent {
    public let objectId: String?
    public let type: ChatEventType = .InterlocutorReceptionConfirmed
    public let conversationId: String
    
    public let messageIds: [String]
}

extension LGChatEventInterlocutorReceptionConfirmed: Decodable {
    public static func decode(j: JSON) -> Decoded<LGChatEventInterlocutorReceptionConfirmed> {
        let init1 = curry(LGChatEventInterlocutorReceptionConfirmed.init)
            <^> j <|? "id"
            <*> j <|  ["data", "conversation_id"]
            <*> j <|| ["data", "message_ids"]
        return init1
    }
}
