//
//  Notification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum NotificationType {
    case modular(modules: NotificationModular)
}

public protocol NotificationModel: BaseModel {
    var createdAt: Date { get }
    var isRead: Bool { get }
    var campaignType: String? { get }
    var type: NotificationType { get }
}
