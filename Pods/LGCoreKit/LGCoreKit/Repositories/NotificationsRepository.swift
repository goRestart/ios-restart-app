//
//  NotificationsRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias NotificationsResult = Result<[NotificationModel], RepositoryError>
public typealias NotificationsCompletion = (NotificationsResult) -> Void

public typealias NotificationsUnreadCountResult = Result<UnreadNotificationsCounts, RepositoryError>
public typealias NotificationsUnreadCountCompletion = (NotificationsUnreadCountResult) -> Void

public protocol NotificationsRepository {

    /**
     Retrieves all notifications from the loged-in user

     - parameter completion: The completion closure
     */
    func index(_ completion: NotificationsCompletion?)

    /**
     Retrieves the unread notifications count.

     - parameter completion: The completion closure.
     */
    func unreadNotificationsCount(_ completion: NotificationsUnreadCountCompletion?)
}
