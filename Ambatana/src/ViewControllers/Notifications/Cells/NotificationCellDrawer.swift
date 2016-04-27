//
//  NotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol NotificationCellDelegate: class {

}

protocol NotificationCellDrawer: TableCellDrawer {
    func cellHeight() -> CGFloat
    func draw(tableViewCell: UITableViewCell, data: Notification, delegate: NotificationCellDelegate?)
}