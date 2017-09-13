//
//  NotificationData.swift
//  LetGo
//
//  Created by Eli Kohen on 28/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum NotificationDataType {
    case modular(modules: NotificationModular, delegate: ModularNotificationCellDelegate?)
}

struct NotificationData {
    let id: String?
    let type: NotificationDataType
    let date: Date
    let isRead: Bool
    let campaignType: String?
    var primaryAction: (() -> Void)?
    let primaryActionCompleted: Bool?

    init(id: String?, type: NotificationDataType, date: Date, isRead: Bool, campaignType: String?,
         primaryAction: (() -> Void)?, primaryActionCompleted: Bool? = nil) {
        self.id = id
        self.type = type
        self.date = date
        self.isRead = isRead
        self.campaignType = campaignType
        self.primaryAction = primaryAction
        self.primaryActionCompleted = primaryActionCompleted
    }
}
