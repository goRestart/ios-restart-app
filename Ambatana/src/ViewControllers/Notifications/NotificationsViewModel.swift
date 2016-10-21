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
    weak var tabNavigator: TabNavigator?

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
        case .Rating, .RatingUpdated: // Rating notifications not implemented yet
            return nil
        case let .Like(_, _, productTitle, userId, userImageUrl, userName):

            return buildLikeNotification(userId, userName: userName, userImage: userImageUrl, productTitle: productTitle,
                                         date: notification.createdAt, isRead: notification.isRead)

        case let .Sold(productId, productImageUrl, _, _, _, _):
            return buildSoldNotification(productId, productImage: productImageUrl, date: notification.createdAt,
                                         isRead: notification.isRead)
        }
    }

    private func buildLikeNotification(userId: String?, userName: String?, userImage: String?, productTitle: String?, date: NSDate, isRead: Bool ) -> NotificationData {
        let message: String
        if let productTitle = productTitle where !productTitle.isEmpty {
            message = LGLocalizedString.notificationsTypeLikeWNameWTitle(userName ?? "", productTitle)
        } else {
            message = LGLocalizedString.notificationsTypeLikeWName(userName ?? "")
        }
        let userImagePlaceholder = LetgoAvatar.avatarWithID(userId, name: userName)
        return NotificationData(type: .ProductFavorite, title: "", subtitle: message, date: date, isRead: isRead,
                                primaryAction: { [weak self] in
                                    guard let userId = userId else { return }
                                    let data = UserDetailData.Id(userId: userId, source: .Notifications)
                                    self?.tabNavigator?.openUser(data)
                                },
                                primaryActionText: LGLocalizedString.notificationsTypeLikeButton,
                                icon: UIImage(named: "ic_favorite"),
                                leftImage: userImage,
                                leftImagePlaceholder: userImagePlaceholder)
    }

    private func buildSoldNotification(productId: String?, productImage: String?, date: NSDate, isRead: Bool) -> NotificationData {
        let message = LGLocalizedString.notificationsTypeSold
        let productPlaceholder = UIImage(named: "product_placeholder")
        return NotificationData(type: .ProductSold, title: "", subtitle: message, date: date, isRead: isRead,
                                primaryAction: { [weak self] in
                                    guard let productId = productId else { return }
                                    let data = ProductDetailData.Id(productId: productId)
                                    self?.tabNavigator?.openProduct(data, source: .Notifications)
                                },
                                primaryActionText: LGLocalizedString.notificationsTypeSoldButton,
                                icon: UIImage(named: "ic_dollar_sold"),
                                leftImage: productImage,
                                leftImagePlaceholder: productPlaceholder)
    }

    private func buildWelcomeNotification() -> NotificationData {
        let title = LGLocalizedString.notificationsTypeWelcomeTitle
        let subtitle: String
        if let city = locationManager.currentPostalAddress?.city where !city.isEmpty {
            subtitle = LGLocalizedString.notificationsTypeWelcomeSubtitleWCity(city)
        } else {
            subtitle = LGLocalizedString.notificationsTypeWelcomeSubtitle
        }
        return NotificationData(type: .Welcome, title: title, subtitle: subtitle, date: NSDate(), isRead: true,
                                primaryAction: { [weak self] in self?.delegate?.vmOpenSell() },
                                primaryActionText: LGLocalizedString.notificationsTypeWelcomeButton)
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
        case .Welcome:
            return .Welcome
        }
    }
}
