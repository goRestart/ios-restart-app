//
//  NotificationsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol NotificationsViewModelDelegate: BaseViewModelDelegate {
    func vmOpenSell()
}


class NotificationsViewModel: BaseViewModel {

    weak var delegate: NotificationsViewModelDelegate?
    weak var navigator: NotificationsTabNavigator?

    let viewState = Variable<ViewState>(.Loading)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let notificationsManager: NotificationsManager
    private let locationManager: LocationManager
    private let tracker: Tracker

    private var pendingCountersUpdate = false

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  productRepository: Core.productRepository,
                  userRepository: Core.userRepository,
                  notificationsManager: NotificationsManager.sharedInstance,
                  locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(notificationsRepository: NotificationsRepository, productRepository: ProductRepository,
         userRepository: UserRepository, notificationsManager: NotificationsManager, locationManager: LocationManager,
         tracker: Tracker) {
        self.notificationsRepository = notificationsRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.notificationsManager = notificationsManager
        self.locationManager = locationManager
        self.tracker = tracker

        super.init()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        trackVisit()
        reloadNotifications()
    }

    override func didBecomeInactive() {
        if pendingCountersUpdate {
            pendingCountersUpdate = false
            notificationsManager.updateCounters()
        }
    }

    // MARK: - Public

    var dataCount: Int {
        return notificationsData.count
    }

    func dataAtIndex(index: Int) -> NotificationData? {
        guard 0..<dataCount ~= index else { return nil }
        return notificationsData[index]
    }

    func refresh() {
        reloadNotifications()
    }

    func selectedItemAtIndex(index: Int) {
        guard let data = dataAtIndex(index) else { return }
        trackItemPressed(data.type.eventType)
        data.primaryAction()
    }


    // MARK: - Private methods

    private func reloadNotifications() {
        notificationsRepository.index { [weak self] result in
            guard let strongSelf = self else { return }
            if let notifications = result.value {
                let remoteNotifications = notifications.flatMap{ strongSelf.buildNotification($0) }
                strongSelf.notificationsData = remoteNotifications + [strongSelf.buildWelcomeNotification()]
                if strongSelf.notificationsData.isEmpty {
                    let emptyViewModel = LGEmptyViewModel(icon: UIImage(named: "ic_notifications_empty" ),
                        title:  LGLocalizedString.notificationsEmptyTitle,
                        body: LGLocalizedString.notificationsEmptySubtitle, buttonTitle: LGLocalizedString.tabBarToolTip,
                        action: { [weak self] in self?.delegate?.vmOpenSell() }, secondaryButtonTitle: nil, secondaryAction: nil)

                    strongSelf.viewState.value = .Empty(emptyViewModel)
                } else {
                    strongSelf.viewState.value = .Data
                }
            } else if let error = result.error {
                let emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                    action: { [weak self] in
                        self?.viewState.value = .Loading
                        self?.reloadNotifications()
                    })
                strongSelf.viewState.value = .Error(emptyViewModel)
            }
        }
    }
}


// MARK: - Notifications builder

private extension NotificationsViewModel {

    private func buildNotification(notification: Notification) -> NotificationData? {
        switch notification.type {
        case let .Rating(userId, userImageUrl, userName, _, _):
            return NotificationData(type: .Rating(userId: userId, userName: userName, userImage: userImageUrl),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .RatingUpdated(userId, userImageUrl, userName, _, _):
            return NotificationData(type: .RatingUpdated(userId: userId, userName: userName, userImage: userImageUrl),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .Like(_, _, productTitle, userId, userImageUrl, userName):
            return NotificationData(
                type: .ProductFavorite(userId: userId, userName: userName, productTitle: productTitle, userImage: userImageUrl),
                date: notification.createdAt, isRead: notification.isRead,
                primaryAction: { [weak self] in
                    let data = UserDetailData.Id(userId: userId, source: .Notifications)
                    self?.navigator?.openUser(data)
                })
        case let .Sold(productId, productImageUrl, _, _, _, _):
            return NotificationData(type: .ProductSold(productImage: productImageUrl), date: notification.createdAt,
                                    isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        let data = ProductDetailData.Id(productId: productId)
                                        self?.navigator?.openProduct(data, source: .Notifications)
                                    })
        }
    }

    private func buildWelcomeNotification() -> NotificationData {
        return NotificationData(type: .Welcome(city: locationManager.currentPostalAddress?.city),
                                date: NSDate(), isRead: true, primaryAction: { [weak self] in
                                    self?.delegate?.vmOpenSell()
                                })
    }
}


// MARK: - Trackings

private extension NotificationsViewModel {
    func trackVisit() {
        let event = TrackerEvent.NotificationCenterStart()
        tracker.trackEvent(event)
    }

    func trackItemPressed(type: EventParameterNotificationType) {
        let event = TrackerEvent.NotificationCenterComplete(type)
        tracker.trackEvent(event)
    }
}

private extension NotificationDataType {
    var eventType: EventParameterNotificationType {
        switch self {
        case .ProductSold:
            return .ProductSold
        case .ProductFavorite:
            return .Favorite
        case .Rating:
            return .Rating
        case .RatingUpdated:
            return .RatingUpdated
        case .Welcome:
            return .Welcome
        }
    }
}
