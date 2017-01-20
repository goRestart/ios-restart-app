//
//  NotificationCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class NotificationCellDrawerFactory {

    static let estimatedRowHeight: CGFloat = 80

    static func drawerForNotificationData(_ notification: NotificationData) -> NotificationCellDrawer {
        switch notification.type {
        case .productFavorite:
            return ProductFavoriteNotificationCellDrawer()
        case .productSold:
            return ProductSoldNotificationCellDrawer()
        case .rating, .ratingUpdated:
            return RatingNotificationCellDrawer()
        case .welcome:
            return WelcomeNotificationCellDrawer()
        case .buyersInterested:
            return BuyersInterestedNotificationCellDrawer()
        case .productSuggested:
            return ProductSuggestedNotificationCellDrawer()
        case .facebookFriendshipCreated:
            return FacebookFriendshipNotificationCellDrawer()
        }
    }

    static func registerCells(_ tableView: UITableView) {
        BaseNotificationCellDrawer<NotificationCell>.registerCell(tableView)
        BaseNotificationCellDrawer<BuyersInterestedNotificationCell>.registerCell(tableView)
        WelcomeNotificationCellDrawer.registerCell(tableView)
    }
}
