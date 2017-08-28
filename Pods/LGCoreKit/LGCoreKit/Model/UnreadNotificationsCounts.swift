//
//  NotificationsCounts.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol UnreadNotificationsCounts {
    var listingSold: Int { get }
    var listingLike: Int { get }
    var review: Int { get }
    var reviewUpdated: Int { get }
    var buyersInterested: Int { get }
    var listingSuggested: Int { get }
    var facebookFriendshipCreated: Int { get }
    var modular: Int { get }
    var total: Int { get }
}
