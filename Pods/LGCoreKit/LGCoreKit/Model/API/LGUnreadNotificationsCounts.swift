//
//  LGUnreadNotificationsCounts.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGUnreadNotificationsCounts: UnreadNotificationsCounts {
    let productSold: Int
    let productLike: Int
    let review: Int
    let reviewUpdated: Int
    let total: Int

    init(total: Int?, sold: Int?, like: Int?, review: Int?, reviewUpdated: Int?) {
        self.total = total ?? 0
        self.productSold = sold ?? 0
        self.productLike = like ?? 0
        self.review = review ?? 0
        self.reviewUpdated = reviewUpdated ?? 0
    }
}

extension LGUnreadNotificationsCounts: Decodable {
    /**
     "counts" : {
         "sold": 25,
         "like": 10,
         "review_updated": 10,
         "review": 5,
         "total": 50
     }
     */
    static func decode(j: JSON) -> Decoded<LGUnreadNotificationsCounts> {
        let result = curry(LGUnreadNotificationsCounts.init)
            <^> j <|? "total"
            <*> j <|? "sold"
            <*> j <|? "like"
            <*> j <|? "review"
            <*> j <|? "review_updated"

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGUnreadNotificationsCounts parse error: \(error)")
        }

        return result
    }
}

