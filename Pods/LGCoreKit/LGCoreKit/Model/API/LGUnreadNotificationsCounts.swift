//
//  LGUnreadNotificationsCounts.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGUnreadNotificationsCounts: UnreadNotificationsCounts {
    let modular: Int
    let total: Int

    init(total: Int?, modular: Int?) {
        self.total = total ?? 0
        self.modular = modular ?? 0
    }
}

extension LGUnreadNotificationsCounts: Decodable {
    /**
     "counts" : {
         "sold": 25,
         "like": 10,
         "review": 5,
         "review_updated": 10,
         "buyers_interested": 0,
         "product_suggested": 0,
         "facebook_friendship_created": 10,
         "modular": 10,
         "total": 70
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGUnreadNotificationsCounts> {
        let result1 = curry(LGUnreadNotificationsCounts.init)
        let result2 = result1 <^> j <|? "total"
        let result  = result2 <*> j <|? "modular"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUnreadNotificationsCounts parse error: \(error)")
        }
        return result
    }
}

