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

public typealias NotificationsUnreadCountResult = Result<Int, RepositoryError>
public typealias NotificationsUnreadCountCompletion = NotificationsUnreadCountResult -> Void

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
     Retrieves the unread notifications count.

     - parameter completion: The completion closure.
     */
    public func unreadNotificationsCount(completion: NotificationsUnreadCountCompletion?) {
        dataSource.unreadCount { result in
            handleApiResult(result, completion: completion)
        }
    }
}
