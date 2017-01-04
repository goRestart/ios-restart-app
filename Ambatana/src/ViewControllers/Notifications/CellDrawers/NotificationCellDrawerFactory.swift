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
        case .ProductFavorite:
            return ProductFavoriteNotificationCellDrawer()
        case .productSold:
            return ProductSoldNotificationCellDrawer()
        case .Rating, .RatingUpdated:
            return RatingNotificationCellDrawer()
        case .welcome:
            return WelcomeNotificationCellDrawer()
        case .BuyersInterested:
            return BuyersInterestedNotificationCellDrawer()
        case .ProductSuggested:
            return ProductSuggestedNotificationCellDrawer()
        }
    }

    static func registerCells(_ tableView: UITableView) {
        BaseNotificationCellDrawer<NotificationCell>.registerCell(tableView)
        BaseNotificationCellDrawer<BuyersInterestedNotificationCell>.registerCell(tableView)
        WelcomeNotificationCellDrawer.registerCell(tableView)
    }
}
