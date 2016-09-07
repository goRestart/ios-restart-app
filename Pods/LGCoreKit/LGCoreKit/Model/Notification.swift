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
    case Follow(followerId: String, followerImageUrl: String?, followerUsername: String?, followerRelationship: Bool)
    case Sold(productId: String, productImageUrl: String?, productTitle: String?, userId: String, userImageUrl: String?,
        userName: String?)
}

public protocol Notification: BaseModel {
    var createdAt: NSDate { get }
    var isRead: Bool { get }
    var type: NotificationType { get }
}
