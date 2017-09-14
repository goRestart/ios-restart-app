//
//  ModularNotificationCellDrawer.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class ModularNotificationCellDrawer: BaseTableCellDrawer<ModularNotificationCell> {
    
    static let estimatedRowHeight: CGFloat = 80
    
    func draw(_ cell: ModularNotificationCell, data: NotificationData, delegate: ModularNotificationCellDelegate?) {
        cell.addModularData(with: data.modules, isRead: data.isRead, notificationCampaign: data.campaignType)
        cell.delegate = delegate
    }
    
    static func registerCells(_ tableView: UITableView) {
        BaseTableCellDrawer<ModularNotificationCell>.registerClassCell(tableView)
    }
}
