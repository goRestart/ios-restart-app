//
//  LGChatUnreadMessages.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatUnreadMessages: ChatUnreadMessages {
    let totalUnreadMessages: Int

    init(totalUnreadMessages: Int) {
        self.totalUnreadMessages = totalUnreadMessages
    }
}

extension LGChatUnreadMessages : Decodable {

    /**
     Expects a json in the form:
     {
        "total_unread_messages_count": 2,
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGChatUnreadMessages> {
        let result1 = curry(LGChatUnreadMessages.init)
        let result  = result1 <^> j <| "total_unread_messages_count"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGChatUnreadMessages parse error: \(error)")
        }
        return result
    }
}
