//
//  NotificationsManager.swift
//  LetGo
//
//  Created by Eli Kohen on 29/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import Kahuna

class NotificationsManager {

    // Singleton
    static let sharedInstance = NotificationsManager()

    // Rx
    let unreadMessagesCount = Variable<Int?>(nil)
    let unreadNotificationsCount = Variable<Int?>(nil)
    var globalCount: Observable<Int?> {
        return Observable.combineLatest(unreadMessagesCount.asObservable(), unreadNotificationsCount.asObservable()) {
            (unreadMessages: Int?, notifications: Int?) in
            guard let unreadMessages = unreadMessages, notifications = notifications else { return nil }
            return unreadMessages + notifications
        }
    }

    private let disposeBag = DisposeBag()

    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository

    private var requesting = false


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager, myUserRepository: Core.myUserRepository)
    }

    init(sessionManager: SessionManager, myUserRepository: MyUserRepository) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(login),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground),
                                                         name: UIApplicationWillEnterForegroundNotification, object: nil)

        setupAppBadgeRxBinding()
        setupDeepLinksRxBinding()
        updateCounters()
    }

    // MARK: - Private

    private func setupAppBadgeRxBinding() {
        globalCount.bindNext { count in
            guard let count = count else { return }
            Kahuna.sharedInstance().badgeNumber = count
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        }.addDisposableTo(disposeBag)
    }

    private func setupDeepLinksRxBinding() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.bindNext { [weak self] _ in
            self?.updateCounters()
        }.addDisposableTo(disposeBag)
    }

    dynamic private func login() {
        updateCounters()
    }

    dynamic private func logout() {
        unreadMessagesCount.value = 0
        unreadNotificationsCount.value = 0
    }

    dynamic private func applicationWillEnterForeground() {
        updateCounters()
    }

    func updateCounters() {
        guard sessionManager.loggedIn && !requesting else { return }
        requesting = true
        if FeatureFlags.notificationsSection {
            myUserRepository.retrieveCounters { [weak self] result in
                self?.requesting = false
                guard let counters = result.value else { return }
                self?.unreadNotificationsCount.value = counters.unreadNotifications
                self?.unreadMessagesCount.value = counters.unreadMessages
            }
        } else {
            Core.oldChatRepository.retrieveUnreadMessageCountWithCompletion { [weak self] result in
                self?.requesting = false
                guard let count = result.value else { return }
                self?.unreadNotificationsCount.value = 0
                self?.unreadMessagesCount.value = count
            }
        }
    }
}
