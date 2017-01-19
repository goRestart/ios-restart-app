//
//  MockNotificationsRepository.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class MockNotificationsRepository: NotificationsRepository {

    var notificationsResult: NotificationsResult?
    var notificationsUnreadCountResult: NotificationsUnreadCountResult?

    func index(_ completion: NotificationsCompletion?) {
        performAfterDelayWithCompletion(completion, result: notificationsResult)
    }

    func unreadNotificationsCount(_ completion: NotificationsUnreadCountCompletion?) {
        performAfterDelayWithCompletion(completion, result: notificationsUnreadCountResult)
    }
}
