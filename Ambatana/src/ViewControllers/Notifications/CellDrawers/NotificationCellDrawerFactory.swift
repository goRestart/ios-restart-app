//
//  NotificationCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

public class NotificationCellDrawerFactory {

    static let estimatedRowHeight: CGFloat = 80

    static func drawerForNotificationData(notification: NotificationData) -> NotificationCellDrawer {
        switch notification.type {
        case .ProductFavorite:
            return ProductFavoriteNotificationCellDrawer()
        case .ProductSold:
            return ProductSoldNotificationCellDrawer()
        case .Rating, .RatingUpdated:
            return RatingNotificationCellDrawer()
        case .Welcome:
            return WelcomeNotificationCellDrawer()
        }
    }

    static func registerCells(tableView: UITableView) {
        BaseNotificationCellDrawer<NotificationCell>.registerCell(tableView)
        WelcomeNotificationCellDrawer.registerCell(tableView)
    }
}
