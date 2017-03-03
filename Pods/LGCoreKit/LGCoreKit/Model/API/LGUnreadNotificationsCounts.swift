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
    let productSold: Int
    let productLike: Int
    let review: Int
    let reviewUpdated: Int
    let buyersInterested: Int
    let productSuggested: Int
    let facebookFriendshipCreated: Int
    let modular: Int
    let total: Int

    init(total: Int?, sold: Int?, like: Int?, review: Int?, reviewUpdated: Int?, buyersInterested: Int?,
         productSuggested: Int?, facebookFriendshipCreated: Int?, modular: Int?) {
        self.total = total ?? 0
        self.productSold = sold ?? 0
        self.productLike = like ?? 0
        self.review = review ?? 0
        self.reviewUpdated = reviewUpdated ?? 0
        self.buyersInterested = buyersInterested ?? 0
        self.productSuggested = productSuggested ?? 0
        self.facebookFriendshipCreated = facebookFriendshipCreated ?? 0
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
        let result = curry(LGUnreadNotificationsCounts.init)
            <^> j <|? "total"
            <*> j <|? "sold"
            <*> j <|? "like"
            <*> j <|? "review"
            <*> j <|? "review_updated"
            <*> j <|? "buyers_interested"
            <*> j <|? "product_suggested"
            <*> j <|? "facebook_friendship_created"
            <*> j <|? "modular"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUnreadNotificationsCounts parse error: \(error)")
        }

        return result
    }
}

