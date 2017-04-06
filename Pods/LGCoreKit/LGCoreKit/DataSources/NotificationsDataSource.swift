//
//  NotificationsDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias NotificationsDataSourceResult = Result<[NotificationModel], ApiError>
typealias NotificationsDataSourceCompletion = (NotificationsDataSourceResult) -> Void

typealias NotificationsDataSourceUnreadCountResult = Result<UnreadNotificationsCounts, ApiError>
typealias NotificationsDataSourceUnreadCountCompletion = (NotificationsDataSourceUnreadCountResult) -> Void


protocol NotificationsDataSource {
    func index(_ completion: NotificationsDataSourceCompletion?)
    func unreadCount(_ completion: NotificationsDataSourceUnreadCountCompletion?)
}
