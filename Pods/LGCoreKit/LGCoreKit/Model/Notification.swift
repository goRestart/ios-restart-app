//
//  Notification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum NotificationType {
    case like(product: NotificationListing, user: NotificationUser)
    case sold(product: NotificationListing, user: NotificationUser)
    case rating(user: NotificationUser, value: Int, comments: String?)
    case ratingUpdated(user: NotificationUser, value: Int, comments: String?)
    case buyersInterested(product: NotificationListing, buyers: [NotificationUser])
    case productSuggested(product: NotificationListing, seller: NotificationUser)
    case facebookFriendshipCreated(user: NotificationUser, facebookUsername: String)
    case modular(modules: NotificationModular)
}

public protocol NotificationModel: BaseModel {
    var createdAt: Date { get }
    var isRead: Bool { get }
    var campaignType: String? { get }
    var type: NotificationType { get }
}
