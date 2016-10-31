//
//  NotificationsManager.swift
//  LetGo
//
//  Created by Eli Kohen on 29/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class NotificationsManager {

    // Singleton
    static let sharedInstance = NotificationsManager()

    // Rx
    let unreadMessagesCount = Variable<Int?>(nil)
    let unreadNotificationsCount = Variable<Int?>(nil)
    var globalCount: Observable<Int?> {
        return Observable.combineLatest(unreadMessagesCount.asObservable(), unreadNotificationsCount.asObservable()) {
            (unreadMessages: Int?, notifications: Int?) in
            let chatCount = unreadMessages ?? 0
            let notificationsCount = notifications ?? 0
            return chatCount + notificationsCount
        }
    }

    private let disposeBag = DisposeBag()

    private let sessionManager: SessionManager
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let notificationsRepository: NotificationsRepository

    private var requestingChat = false
    private var requestingNotifications = false


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager, chatRepository: Core.chatRepository,
                  oldChatRepository: Core.oldChatRepository, notificationsRepository: Core.notificationsRepository)
    }

    init(sessionManager: SessionManager, chatRepository: ChatRepository, oldChatRepository: OldChatRepository,
         notificationsRepository: NotificationsRepository) {
        self.sessionManager = sessionManager
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.notificationsRepository = notificationsRepository
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
        setupRxBindings()
        updateCounters()
    }

    func updateCounters() {
        requestChatCounters()
        requestNotificationCounters()
    }

    func updateChatCounters() {
        requestChatCounters()
    }

    func updateNotificationCounters() {
        requestNotificationCounters()
    }

    // MARK: - Private

    private func setupRxBindings() {
        globalCount.bindNext { count in
            guard let count = count else { return }
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        }.addDisposableTo(disposeBag)

        if FeatureFlags.websocketChat {
            chatRepository.chatEvents.filter { event in
                switch event.type {
                case .InterlocutorMessageSent:
                    return true
                default:
                    return false
                }
            }.bindNext{ [weak self] event in
                self?.requestChatCounters()
            }.addDisposableTo(disposeBag)
        } else {
            DeepLinksRouter.sharedInstance.chatDeepLinks.bindNext { [weak self] _ in
                self?.requestChatCounters()
            }.addDisposableTo(disposeBag)
        }
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

    private func requestChatCounters() {
        guard sessionManager.loggedIn && !requestingChat else { return }
        requestingChat = true

        if FeatureFlags.websocketChat {
            chatRepository.chatUnreadMessagesCount() { [weak self] result in
                self?.requestingChat = false
                guard let count = result.value?.totalUnreadMessages else { return }
                self?.unreadMessagesCount.value = count
            }
        } else {
            oldChatRepository.retrieveUnreadMessageCountWithCompletion { [weak self] result in
                self?.requestingChat = false
                guard let count = result.value else { return }
                self?.unreadMessagesCount.value = count
            }
        }
    }

    private func requestNotificationCounters() {
        guard FeatureFlags.notificationsSection && sessionManager.loggedIn && !requestingNotifications else { return }
        requestingNotifications = true
        notificationsRepository.unreadNotificationsCount() { [weak self] result in
            self?.requestingNotifications = false
            guard let notificationCounts = result.value else { return }
            self?.unreadNotificationsCount.value = notificationCounts.totalVisibleCount
        }
    }
}


// MARK: - UnreadNotificationsCounts

private extension UnreadNotificationsCounts {
    var totalVisibleCount: Int {
        if FeatureFlags.userReviews {
            return productLike + productSold + review + reviewUpdated
        } else {
            return productLike + productSold
        }
    }
}
