//
//  LGUserCounter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGUserCounters: UserCounters {
    let unreadMessages: Int
    let unreadNotifications: Int
}

extension LGUserCounters : Decodable {

    /**
     Expects a json in the form:
     {
     "unreadMessages": 2,
     "unreadNotifications": 4
     }
     */
    static func decode(j: JSON) -> Decoded<LGUserCounters> {

        let result = curry(LGUserCounters.init)
            <^> j <| "unreadMessages"
            <*> j <| "unreadNotifications"

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGUserCounters parse error: \(error)")
        }

        return result
    }
}
