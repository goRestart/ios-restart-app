//
//  MockNotificationsUnreadCounts.swift
//  LetGo
//
//  Created by Eli Kohen on 18/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct MockUnreadNotificationsCounts: UnreadNotificationsCounts {
    var productSold: Int
    var productLike: Int
    var review: Int
    var reviewUpdated: Int
    var buyersInterested: Int
    var productSuggested: Int
    var facebookFriendshipCreated: Int
    var total: Int

    init(sold: Int, like: Int, review: Int, reviewUpdate: Int, buyers: Int, suggested: Int, facebook: Int, total: Int) {
        self.productSold = sold
        self.productLike = like
        self.review = review
        self.reviewUpdated = reviewUpdate
        self.buyersInterested = buyers
        self.productSuggested = suggested
        self.facebookFriendshipCreated = facebook
        self.total = total
    }
}
