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
    // Not updated to Listing as it is going to be remove: ABIOS-2662
    static func drawerForNotificationData(_ notification: NotificationData) -> NotificationCellDrawer {
        switch notification.type {
        case .modular:
            return ModularNotificationCellDrawer()
        }
    }

    static func registerCells(_ tableView: UITableView) {
        BaseNotificationCellDrawer<ModularNotificationCell>.registerClassCell(tableView)
    }
}
