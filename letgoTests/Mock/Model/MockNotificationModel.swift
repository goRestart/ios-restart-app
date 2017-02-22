//
//  MockNotificationModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 13/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

struct MockNotificationModel: NotificationModel {
    
    var objectId: String?
    var createdAt: Date
    var updatedAt: Date?
    var isRead: Bool
    var type: NotificationType
    
}
