//
//  NotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol NotificationCellDrawer: TableCellDrawer {
    func draw(tableViewCell: UITableViewCell, data: NotificationData)
}
