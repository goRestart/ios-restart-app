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
        let result1 = curry(LGUnreadNotificationsCounts.init)
        let result2 = result1 <^> j <|? "total"
        let result3 = result2 <*> j <|? "sold"
        let result4 = result3 <*> j <|? "like"
        let result5 = result4 <*> j <|? "review"
        let result6 = result5 <*> j <|? "review_updated"
        let result7 = result6 <*> j <|? "buyers_interested"
        let result8 = result7 <*> j <|? "product_suggested"
        let result9 = result8 <*> j <|? "facebook_friendship_created"
        let result  = result9 <*> j <|? "modular"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUnreadNotificationsCounts parse error: \(error)")
        }
        return result
    }
}

