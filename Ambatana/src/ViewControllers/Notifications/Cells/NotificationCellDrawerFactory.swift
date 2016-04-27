//
//  NotificationCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

public class NotificationCellDrawerFactory {

    static func drawerForNotification(notification: Notification) -> NotificationCellDrawer {
        //TODO: IMPLEMENT
        return ProductSoldNotificationCellDrawer()
    }

    static func registerCells(tableView: UITableView) {
        //TODO: IMPLEMENT
    }
}