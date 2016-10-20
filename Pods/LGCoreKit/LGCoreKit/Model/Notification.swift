//
//  Notification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum NotificationType {
    case Like(productId: String, productImageUrl: String?, productTitle: String?, userId: String, userImageUrl: String?,
        userName: String?)
    case Sold(productId: String, productImageUrl: String?, productTitle: String?, userId: String, userImageUrl: String?,
        userName: String?)
    case Rating(userId: String, userImageUrl: String?, userName: String?, value: Int, comments: String?)
    case RatingUpdated(userId: String, userImageUrl: String?, userName: String?, value: Int, comments: String?)
}

public protocol Notification: BaseModel {
    var createdAt: NSDate { get }
    var isRead: Bool { get }
    var type: NotificationType { get }
}
