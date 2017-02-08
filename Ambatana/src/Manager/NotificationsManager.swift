//
//  NotificationsManager.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import RxSwift

protocol NotificationsManager {

    // Rx
    var unreadMessagesCount: Variable<Int?> { get }
    var favoriteCount: Variable<Int?> { get }
    var unreadNotificationsCount: Variable<Int?> { get }
    var globalCount: Observable<Int> { get }
    var marketingNotifications: Variable<Bool> { get }
    var loggedInMktNofitications: Variable<Bool> { get }

    func setup()
    func updateCounters()
    func updateChatCounters()
    func updateNotificationCounters()
    func requestFavoriteCounter()
    func increaseFavoriteCounter()
    func decreaseFavoriteCounter()
    func clearFavoriteCounter()
}
