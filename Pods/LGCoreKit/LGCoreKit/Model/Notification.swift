//
//  Notification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum NotificationType {
    case Like(product: NotificationProduct, user: NotificationUser)
    case Sold(product: NotificationProduct, user: NotificationUser)
    case Rating(user: NotificationUser, value: Int, comments: String?)
    case RatingUpdated(user: NotificationUser, value: Int, comments: String?)
    case BuyersInterested(product: NotificationProduct, buyers: [NotificationUser])
    case ProductSuggested(product: NotificationProduct, seller: NotificationUser)
}

public protocol Notification: BaseModel {
    var createdAt: NSDate { get }
    var isRead: Bool { get }
    var type: NotificationType { get }
}
