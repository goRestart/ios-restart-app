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
    
    func draw(_ cell: UITableViewCell, data: NotificationData, delegate: ModularNotificationCellDelegate?) {
        guard let modularNotificationCell = cell as? ModularNotificationCell else { return }
        modularNotificationCell.addModularData(with: data.modules,
                                               isRead: data.isRead,
                                               notificationCampaign: data.campaignType)
        modularNotificationCell.delegate = delegate
    }
}
