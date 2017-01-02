//
//  NotificationsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 26/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift


class NotificationsViewModel: BaseViewModel {

    weak var navigator: NotificationsTabNavigator?

    let viewState = Variable<ViewState>(.Loading)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    private let locationManager: LocationManager
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  productRepository: Core.productRepository,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository,
                  notificationsManager: NotificationsManager.sharedInstance,
                  locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }

    init(notificationsRepository: NotificationsRepository, productRepository: ProductRepository,
         userRepository: UserRepository, myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager, locationManager: LocationManager,
         tracker: Tracker, featureFlags: FeatureFlaggeable) {
        self.notificationsRepository = notificationsRepository
        self.productRepository = productRepository
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.notificationsManager = notificationsManager
        self.locationManager = locationManager
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            setupRx()
        }
        trackVisit()
        reloadNotifications()
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
        data.primaryAction?()
    }


    // MARK: - Private methods

    private func setupRx() {
        let loggedOut = myUserRepository.rx_myUser.filter { return $0 == nil }
        loggedOut.subscribeNext { [weak self] _ in
            self?.viewState.value = .Loading
        }.addDisposableTo(disposeBag)
    }

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
                        action: { [weak self] in self?.navigator?.openSell(.Notifications) },
                        secondaryButtonTitle: nil, secondaryAction: nil)

                    strongSelf.viewState.value = .Empty(emptyViewModel)
                } else {
                    strongSelf.viewState.value = .Data
                    strongSelf.afterReloadOk()
                }
            } else if let error = result.error {
                switch error {
                    case .Forbidden, .Internal, .NotFound, .ServerError, .TooManyRequests, .Unauthorized, .UserNotVerified,
                    .Network(errorCode: _, onBackground: false):
                        if let emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                            action: { [weak self] in
                                self?.viewState.value = .Loading
                                self?.reloadNotifications()
                            }) {
                            strongSelf.viewState.value = .Error(emptyViewModel)
                    }
                    case .Network(errorCode: _, onBackground: true):
                        break
                }
            }
        }
    }

    private func afterReloadOk() {
        notificationsManager.updateNotificationCounters()
    }

    private func markCompleted(data: NotificationData) {
        guard let primaryActionCompleted = data.primaryActionCompleted where !primaryActionCompleted else { return }
        guard data.id != nil else { return }
        guard let index = notificationsData.indexOf({ $0.id != nil && $0.id == data.id }) else { return }
        let completedData = NotificationData(id: data.id, type: data.type, date: data.date, isRead: data.isRead,
                                             primaryAction: nil, primaryActionCompleted: true)
        notificationsData[index] = completedData
        viewState.value = .Data
    }
}


// MARK: - Notifications builder

private extension NotificationsViewModel {

    private func buildNotification(notification: Notification) -> NotificationData? {
        switch notification.type {
        case let .Rating(user, _, _):
            guard featureFlags.userReviews else { return nil }
            return NotificationData(id: notification.objectId,
                                    type: .Rating(user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .RatingUpdated(user, _, _):
            guard featureFlags.userReviews else { return nil }
            return NotificationData(id: notification.objectId,
                                    type: .RatingUpdated(user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .Like(product, user):
            return NotificationData(id: notification.objectId,
                                    type: .ProductFavorite(product: product, user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        let data = UserDetailData.Id(userId: user.id, source: .Notifications)
                                        self?.navigator?.openUser(data)
                                    })
        case let .Sold(product, _):
            return NotificationData(id: notification.objectId,
                                    type: .ProductSold(productImage: product.image), date: notification.createdAt,
                                    isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        let data = ProductDetailData.Id(productId: product.id)
                                        self?.navigator?.openProduct(data, source: .Notifications,
                                                                     showKeyboardOnFirstAppearIfNeeded: false)
                                    })
        case let .BuyersInterested(product, buyers):
            var data = NotificationData(id: notification.objectId,
                                    type: .BuyersInterested(product: product, buyers: buyers),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: nil,
                                    primaryActionCompleted: false)
            data.primaryAction = { [weak self] in
                self?.navigator?.openPassiveBuyers(product.id, actionCompletedBlock: { [weak self] in
                    self?.markCompleted(data)
                })
            }
            return data
        case let .ProductSuggested(product, seller):
            return NotificationData(id: notification.objectId,
                                    type: .ProductSuggested(product: product, seller: seller),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    primaryAction: { [weak self] in
                                        let data = ProductDetailData.Id(productId: product.id)
                                        self?.navigator?.openProduct(data, source: .Notifications,
                                                                     showKeyboardOnFirstAppearIfNeeded: true)
                                    })
        }
    }

    private func buildWelcomeNotification() -> NotificationData {
        return NotificationData(id: nil, type: .Welcome(city: locationManager.currentPostalAddress?.city),
                                date: NSDate(), isRead: true, primaryAction: { [weak self] in
                                    self?.navigator?.openSell(.Notifications)
                                })
    }
}


// MARK: - Trackings

private extension NotificationsViewModel {
    func trackVisit() {
        let event = TrackerEvent.notificationCenterStart()
        tracker.trackEvent(event)
    }

    func trackItemPressed(type: EventParameterNotificationType) {
        let event = TrackerEvent.notificationCenterComplete(type)
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
        case .BuyersInterested:
            return .BuyersInterested
        case .ProductSuggested:
            return .ProductSuggested
        }
    }
}
