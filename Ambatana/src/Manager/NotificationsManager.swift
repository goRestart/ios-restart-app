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
    let marketingNotifications: Variable<Bool>
    var loggedInMktNofitications: Observable<Bool> {
        return marketingNotifications.asObservable().map { [weak self] enabled in
            if let loggedIn = self?.loggedIn.value, !loggedIn { return true }
            return enabled
        }
    }
    
    fileprivate let disposeBag = DisposeBag()

    private let sessionManager: SessionManager
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let notificationsRepository: NotificationsRepository
    fileprivate let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable

    fileprivate var loggedIn: Variable<Bool>
    private var requestingChat = false
    private var requestingNotifications = false


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager, chatRepository: Core.chatRepository,
                  oldChatRepository: Core.oldChatRepository, notificationsRepository: Core.notificationsRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }

    init(sessionManager: SessionManager, chatRepository: ChatRepository, oldChatRepository: OldChatRepository,
         notificationsRepository: NotificationsRepository, keyValueStorage: KeyValueStorage, featureFlags: FeatureFlaggeable) {
        self.sessionManager = sessionManager
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.notificationsRepository = notificationsRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.loggedIn = Variable<Bool>(sessionManager.loggedIn)
        let enabledMktNotifications = sessionManager.loggedIn && keyValueStorage.userMarketingNotifications
        self.marketingNotifications = Variable<Bool>(enabledMktNotifications)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground),
                                                         name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        setupRxBindings()
        updateCounters()
        setupMarketingNotifications()
    }

    func updateCounters() {
        requestChatCounters()
        requestFavoriteCounter()
        requestNotificationCounters()
    }

    func updateChatCounters() {
        requestChatCounters()
    }

    func updateNotificationCounters() {
        requestNotificationCounters()
    }
    
    func requestFavoriteCounter() {
        let value = keyValueStorage.productsMarkAsFavorite ?? 0
        favoriteCount.value = value > 0 ? 1 : nil
    }
    
    
    func increaseFavoriteCounter() {
        guard featureFlags.favoriteWithBadgeOnProfile else { return }
        let actualValue = keyValueStorage.productsMarkAsFavorite ?? 0
        let increasedFavoriteValue = actualValue + 1
        keyValueStorage.productsMarkAsFavorite = increasedFavoriteValue
        favoriteCount.value = 1
    }
    
    func decreaseFavoriteCounter() {
        guard featureFlags.favoriteWithBadgeOnProfile else { return }
        let actualValue = keyValueStorage.productsMarkAsFavorite ?? 0
        let decreasedFavoriteValue = actualValue - 1
        if decreasedFavoriteValue > 0 {
            keyValueStorage.productsMarkAsFavorite = decreasedFavoriteValue
            favoriteCount.value = 1
        } else {
            clearFavoriteCounter()
        }
        
    }
    
    func clearFavoriteCounter() {
        keyValueStorage.productsMarkAsFavorite = nil
        favoriteCount.value = nil
    }

    // MARK: - Private

    private func setupRxBindings() {
        sessionManager.sessionEvents.bindNext { [weak self] event in
            switch event {
            case .login:
                self?.updateCounters()
            case .logout:
                self?.unreadMessagesCount.value = 0
                self?.unreadNotificationsCount.value = 0
            }
        }.addDisposableTo(disposeBag)

        sessionManager.sessionEvents.map { $0.isLogin }.bindTo(loggedIn).addDisposableTo(disposeBag)

        globalCount.bindNext { count in
            UIApplication.shared.applicationIconBadgeNumber = count
        }.addDisposableTo(disposeBag)

        if featureFlags.websocketChat {
            chatRepository.chatEvents.filter { event in
                switch event.type {
                case .interlocutorMessageSent:
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

    dynamic private func applicationWillEnterForeground() {
        updateCounters()
    }

    private func requestChatCounters() {
        guard sessionManager.loggedIn && !requestingChat else { return }
        requestingChat = true

        if featureFlags.websocketChat {
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
        guard featureFlags.notificationsSection && sessionManager.loggedIn && !requestingNotifications else { return }
        requestingNotifications = true
        notificationsRepository.unreadNotificationsCount() { [weak self] result in
            self?.requestingNotifications = false
            guard let notificationCounts = result.value, let featureFlags = self?.featureFlags else { return }
            self?.unreadNotificationsCount.value = notificationCounts.totalVisibleCount(featureFlags: featureFlags)
        }
    }
}


// MARK: - MarketingNotifications {

fileprivate extension NotificationsManager {
    func setupMarketingNotifications() {
        marketingNotifications.asObservable().skip(1).bindNext { [weak self] value in
            self?.keyValueStorage.userMarketingNotifications = value
        }.addDisposableTo(disposeBag)

        loggedIn.asObservable().skip(1).filter { $0 }.bindNext { [weak self] _ in
            guard let keyValueStorage = self?.keyValueStorage else { return }
            self?.marketingNotifications.value = keyValueStorage.userMarketingNotifications
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UnreadNotificationsCounts

fileprivate extension UnreadNotificationsCounts {
    func totalVisibleCount(featureFlags: FeatureFlaggeable) -> Int {
        let totalWoReviews = productLike + productSold + buyersInterested + productSuggested + facebookFriendshipCreated
        return featureFlags.userReviews ? totalWoReviews + review + reviewUpdated : totalWoReviews
    }
}
