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
    var globalCount: Observable<Int?> {
        return Observable.combineLatest(unreadMessagesCount.asObservable(), unreadNotificationsCount.asObservable(),
                                        favoriteCount.asObservable()) {
                                        (unreadMessages: Int?, notifications: Int?, favorites: Int?) in
            let chatCount = unreadMessages ?? 0
            let notificationsCount = notifications ?? 0
            let favorites = favorites ?? 0
            return chatCount + notificationsCount + favorites
        }
    }
    let marketingNotifications: Variable<Bool>
    var loggedInMktNofitications: Observable<Bool> {
        return Observable.combineLatest(marketingNotifications.asObservable(), loggedIn.asObservable(),
                                        resultSelector: { enabled, loggedIn in
                                            guard loggedIn else { return true }
                                            return enabled
        })
    }

    private let disposeBag = DisposeBag()

    private let sessionManager: SessionManager
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let notificationsRepository: NotificationsRepository
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable

    private var loggedIn: Variable<Bool>
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillEnterForeground),
                                                         name: UIApplicationWillEnterForegroundNotification, object: nil)
        setupRxBindings()
        updateCounters()
        setupMarketingNotifications()
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
    
    
    func increaseFavoriteCounter() {
        let increasedFavoriteValue = keyValueStorage.productsMarkAsFavorite ?? 0 + 1
        keyValueStorage.productsMarkAsFavorite = increasedFavoriteValue
        favoriteCount.value = increasedFavoriteValue
    }
    
    func clearFavoriteCounter() {
        keyValueStorage.productsMarkAsFavorite = nil
        favoriteCount.value = nil
    }

    // MARK: - Private

    private func setupRxBindings() {
        sessionManager.sessionEvents.bindNext { [weak self] event in
            switch event {
            case .Login:
                self?.updateCounters()
            case .Logout:
                self?.unreadMessagesCount.value = 0
                self?.unreadNotificationsCount.value = 0
            }
        }.addDisposableTo(disposeBag)

        sessionManager.sessionEvents.map { $0.isLogin }.bindTo(loggedIn).addDisposableTo(disposeBag)

        globalCount.bindNext { count in
            guard let count = count else { return }
            UIApplication.sharedApplication().applicationIconBadgeNumber = count
        }.addDisposableTo(disposeBag)

        if featureFlags.websocketChat {
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
            guard let notificationCounts = result.value else { return }
            self?.unreadNotificationsCount.value = notificationCounts.totalVisibleCount
        }
    }
}


// MARK: - MarketingNotifications {

private extension NotificationsManager {
    func setupMarketingNotifications() {
        marketingNotifications.asObservable().skip(1).bindNext { [weak self] value in
            self?.keyValueStorage.userMarketingNotifications = value
        }.addDisposableTo(disposeBag)

        loggedIn.asObservable().filter { $0 }.bindNext { [weak self] _ in
            guard let keyValueStorage = self?.keyValueStorage else { return }
            self?.marketingNotifications.value = keyValueStorage.userMarketingNotifications
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - UnreadNotificationsCounts

private extension UnreadNotificationsCounts {
    var totalVisibleCount: Int {
        if FeatureFlags.sharedInstance.userReviews {
            return productLike + productSold + review + reviewUpdated
        } else {
            return productLike + productSold
        }
    }
}
