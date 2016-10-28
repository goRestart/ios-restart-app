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
        case .ProductFavorite, .ProductSold:
            return ProductNotificationCellDrawer()
        case .Rating, .RatingUpdated:
            return RatingNotificationCellDrawer()
        case .Welcome:
            return WelcomeNotificationCellDrawer()
        }
    }

    static func registerCells(tableView: UITableView) {
        ProductNotificationCellDrawer.registerCell(tableView)
        RatingNotificationCellDrawer.registerCell(tableView)
        WelcomeNotificationCellDrawer.registerCell(tableView)
    }
}
