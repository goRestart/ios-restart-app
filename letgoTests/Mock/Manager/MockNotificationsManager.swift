//
//  MockNotificationsManager.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxSwift

class MockNotificationsManager: NotificationsManager {

    let unreadMessagesCount = Variable<Int?>(nil)
    let favoriteCount = Variable<Int?>(nil)
    let unreadNotificationsCount = Variable<Int?>(nil)
    var globalCount: Observable<Int> {
        return Observable.combineLatest(unreadMessagesCount.asObservable(), unreadNotificationsCount.asObservable()) {
                                        (unreadMessages: Int?, notifications: Int?) in
            let chatCount = unreadMessages ?? 0
            let notificationsCount = notifications ?? 0
            return chatCount + notificationsCount
        }
    }
    let marketingNotifications = Variable<Bool>(false)
    let loggedInMktNofitications = Variable<Bool>(false)
    var engagementBadgingNotifications = Variable<Bool>(false)
    
    var updateCountersCalled: Bool = false

    func setup() {  }
    func updateCounters() {
        updateCountersCalled = true
    }
    func updateChatCounters() { }
    func updateNotificationCounters() { }
    func requestFavoriteCounter() { }
    func increaseFavoriteCounter() { }
    func decreaseFavoriteCounter() { }
    func clearFavoriteCounter() { }
    func clearNewSellFeatureIndicator() { }
    func showEngagementBadge() { }
    func hideEngagementBadge() { }
}
