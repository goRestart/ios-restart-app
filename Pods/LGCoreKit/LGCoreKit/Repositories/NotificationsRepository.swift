//
//  NotificationsRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias NotificationsResult = Result<[Notification], RepositoryError>
public typealias NotificationsCompletion = NotificationsResult -> Void

public typealias NotificationsEmptyResult = Result<Void, RepositoryError>
public typealias NotificationsEmptyCompletion = NotificationsEmptyResult -> Void

public final class NotificationsRepository {

    let dataSource: NotificationsDataSource

    // MARK: - Lifecycle

    init(dataSource: NotificationsDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    /**
     Retrieves all notifications from the loged-in user

     - parameter completion: The completion closure
     */
    public func index(completion: NotificationsCompletion?) {
        dataSource.index { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Marks all notifications from the loged-in user as read

     - parameter completion: The completion closure
     */
    public func markAllAsRead(completion: NotificationsEmptyCompletion?) {
        dataSource.markAllAsRead { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Marks as read some notifications from the loged-in user

     - parameter notificationIds: Array of the notifications willing to be marked as read
     - parameter completion:      The completion closure
     */
    public func markAsRead(notificationIds: [String], completion: NotificationsEmptyCompletion?) {
        guard !notificationIds.isEmpty else {
            completion?(NotificationsEmptyResult(error: .Internal(message:"NotificationIds array is empty")))
            return
        }
        dataSource.markAsRead(notificationIds) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
