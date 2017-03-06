//
//  ModularNotificationCellDrawer.swift
//  LetGo
//
//  Created by Juan Iglesias on 28/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


class ModularNotificationCellDrawer: BaseNotificationCellDrawer<ModularNotificationCell> {
    
    override func draw(_ cell: ModularNotificationCell, data: NotificationData) {
        switch data.type {
        case let .modular(modules, delegate):
            cell.addModularData(with: modules)
            cell.delegate = delegate
        default:
            return
        }
    }
}
