//
//  LGNotificationsRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result


final class LGNotificationsRepository: NotificationsRepository {

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
    func index(_ completion: NotificationsCompletion?) {
        dataSource.index { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Retrieves the unread notifications count.

     - parameter completion: The completion closure.
     */
    func unreadNotificationsCount(_ completion: NotificationsUnreadCountCompletion?) {
        dataSource.unreadCount { result in
            handleApiResult(result, completion: completion)
        }
    }
}

