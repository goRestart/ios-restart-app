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
            let chatCount = unreadMessages ?? 0
            let notificationsCount = notifications ?? 0
            return chatCount + notificationsCount
        }
    }

    private let disposeBag = DisposeBag()

    private let sessionManager: SessionManager
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository

    private var requestingChat = false
    private var requestingNotifications = false


    // MARK: - Lifecycle

    convenience init() {
        self.init(sessionManager: Core.sessionManager, chatRepository: Core.chatRepository,
                  oldChatRepository: Core.oldChatRepository)
    }

    init(sessionManager: SessionManager, chatRepository: ChatRepository, oldChatRepository: OldChatRepository) {
        self.sessionManager = sessionManager
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
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
        updateChatCounters()
        updateNotificationsCounters()
    }

    // MARK: - Private

    private func setupRxBindings() {
        globalCount.bindNext { count in
            guard let count = count else { return }
            Kahuna.sharedInstance().badgeNumber = count
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
                self?.updateChatCounters()
                self?.markMessageAsReceived(event)
            }.addDisposableTo(disposeBag)
        } else {
            DeepLinksRouter.sharedInstance.chatDeepLinks.bindNext { [weak self] _ in
                self?.updateChatCounters()
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

    private func updateChatCounters() {
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

    private func updateNotificationsCounters() {
        guard FeatureFlags.notificationsSection else { return }
        //TODO: IMPLEMENT WHEN USING NOTIFICATION CENTER
    }

    private func markMessageAsReceived(event: ChatEvent) {
        guard let convId = event.conversationId where sessionManager.loggedIn else { return }
        switch event.type {
        case let .InterlocutorMessageSent(messageId, _, _, _):
            chatRepository.confirmReception(convId, messageIds: [messageId], completion: nil)
        default:
            return
        }
    }
}
