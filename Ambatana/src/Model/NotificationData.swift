//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum NotificationDataType {
    case Welcome(city: String?)
    case ProductFavorite(userId: String?, userName: String?, productTitle: String?, userImage: String?)
    case ProductSold(productImage: String?)
    case Rating(userId: String?, userName: String?, userImage: String?)
    case RatingUpdated(userId: String?, userName: String?, userImage: String?)
}

struct NotificationData {
    let type: NotificationDataType
    let date: NSDate
    let isRead: Bool
    let primaryAction: (() -> Void)

    init(type: NotificationDataType, date: NSDate, isRead: Bool, primaryAction: (() -> Void)) {
        self.type = type
        self.date = date
        self.isRead = isRead
        self.primaryAction = primaryAction
    }
}
