//
//  NotificationsDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias NotificationsDataSourceResult = Result<[Notification], ApiError>
typealias NotificationsDataSourceCompletion = NotificationsDataSourceResult -> Void

typealias NotificationsDataSourceUnreadCountResult = Result<Int, ApiError>
typealias NotificationsDataSourceUnreadCountCompletion = NotificationsDataSourceUnreadCountResult -> Void


protocol NotificationsDataSource {
    func index(completion: NotificationsDataSourceCompletion?)
    func unreadCount(completion: NotificationsDataSourceUnreadCountCompletion?)
}
