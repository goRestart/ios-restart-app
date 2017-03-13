//
//  Notification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum NotificationType {
    case like(product: NotificationProduct, user: NotificationUser)
    case sold(product: NotificationProduct, user: NotificationUser)
    case rating(user: NotificationUser, value: Int, comments: String?)
    case ratingUpdated(user: NotificationUser, value: Int, comments: String?)
    case buyersInterested(product: NotificationProduct, buyers: [NotificationUser])
    case productSuggested(product: NotificationProduct, seller: NotificationUser)
    case facebookFriendshipCreated(user: NotificationUser, facebookUsername: String)
    case modular(modules: NotificationModular)
}

public protocol NotificationModel: BaseModel {
    var createdAt: Date { get }
    var isRead: Bool { get }
    var type: NotificationType { get }
}
