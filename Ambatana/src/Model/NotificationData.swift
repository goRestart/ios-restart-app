//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum NotificationDataType {
    case Welcome(city: String?)
    case ProductFavorite(product: NotificationProduct, user: NotificationUser)
    case ProductSold(productImage: String?)
    case Rating(user: NotificationUser)
    case RatingUpdated(user: NotificationUser)
    case BuyersInterested(product: NotificationProduct, buyers: [NotificationUser])
    case ProductSuggested(product: NotificationProduct, seller: NotificationUser)
}

struct NotificationData {
    let id: String?
    let type: NotificationDataType
    let date: NSDate
    let isRead: Bool
    var primaryAction: (() -> Void)?
    let primaryActionCompleted: Bool?

    init(id: String?, type: NotificationDataType, date: NSDate, isRead: Bool,
         primaryAction: (() -> Void)?, primaryActionCompleted: Bool? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.isRead = isRead
        self.primaryAction = primaryAction
        self.primaryActionCompleted = primaryActionCompleted
    }
}
