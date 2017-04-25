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

    let viewState = Variable<ViewState>(.loading)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let listingRepository: ListingRepository
    private let userRepository: UserRepository
    fileprivate let myUserRepository: MyUserRepository
    private let notificationsManager: NotificationsManager
    fileprivate let locationManager: LocationManager
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    private let disposeBag = DisposeBag()

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  listingRepository: Core.listingRepository,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  locationManager: Core.locationManager,
                  tracker: TrackerProxy.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }

    init(notificationsRepository: NotificationsRepository, listingRepository: ListingRepository,
         userRepository: UserRepository, myUserRepository: MyUserRepository,
         notificationsManager: NotificationsManager, locationManager: LocationManager,
         tracker: Tracker, featureFlags: FeatureFlaggeable) {
        self.notificationsRepository = notificationsRepository
        self.listingRepository = listingRepository
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.notificationsManager = notificationsManager
        self.locationManager = locationManager
        self.tracker = tracker
        self.featureFlags = featureFlags
        super.init()
    }

    override func didBecomeActive(_ firstTime: Bool) {
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

    func dataAtIndex(_ index: Int) -> NotificationData? {
        guard 0..<dataCount ~= index else { return nil }
        return notificationsData[index]
    }

    func refresh() {
        reloadNotifications()
    }

    func selectedItemAtIndex(_ index: Int) {
        guard let data = dataAtIndex(index) else { return }
        trackItemPressed(data.type.eventType)
        data.primaryAction?()
    }
    

    // MARK: - Private methods

    private func setupRx() {
        let loggedOut = myUserRepository.rx_myUser.filter { return $0 == nil }
        loggedOut.subscribeNext { [weak self] _ in
            self?.viewState.value = .loading
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
                        action: { [weak self] in self?.navigator?.openSell(.notifications) },
                        secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: .emptyResults)

                    strongSelf.viewState.value = .empty(emptyViewModel)
                    if let errorReason = emptyViewModel.emptyReason {
                        strongSelf.trackErrorStateShown(reason: errorReason)
                    }
                } else {
                    strongSelf.viewState.value = .data
                    strongSelf.afterReloadOk()
                }
            } else if let error = result.error {
                switch error {
                    case .forbidden, .internalError, .notFound, .serverError, .tooManyRequests, .unauthorized, .userNotVerified,
                    .network(errorCode: _, onBackground: false):
                        if let emptyViewModel = LGEmptyViewModel.respositoryErrorWithRetry(error,
                            action: { [weak self] in
                                self?.viewState.value = .loading
                                self?.reloadNotifications()
                            }) {
                            strongSelf.viewState.value = .error(emptyViewModel)
                            if let errorReason = emptyViewModel.emptyReason {
                                strongSelf.trackErrorStateShown(reason: errorReason)
                            }
                    }
                    case .network(errorCode: _, onBackground: true):
                        break
                }
            }
        }
    }

    private func afterReloadOk() {
        notificationsManager.updateNotificationCounters()
    }

    fileprivate func markCompleted(_ data: NotificationData) {
        guard let primaryActionCompleted = data.primaryActionCompleted, !primaryActionCompleted else { return }
        guard data.id != nil else { return }
        guard let index = notificationsData.index(where: { $0.id != nil && $0.id == data.id }) else { return }
        let completedData = NotificationData(id: data.id, type: data.type, date: data.date, isRead: data.isRead,
                                             campaignType: data.campaignType, primaryAction: nil, primaryActionCompleted: true)
        notificationsData[index] = completedData
        viewState.value = .data
    }
}


// MARK: - Notifications builder

fileprivate extension NotificationsViewModel {

    func buildNotification(_ notification: NotificationModel) -> NotificationData? {
        switch notification.type {
        case let .rating(user, _, _):
            guard featureFlags.userReviews else { return nil }
            return NotificationData(id: notification.objectId,
                                    type: .rating(user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .ratingUpdated(user, _, _):
            guard featureFlags.userReviews else { return nil }
            return NotificationData(id: notification.objectId,
                                    type: .ratingUpdated(user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        self?.navigator?.openMyRatingList()
                                    })
        case let .like(product, user):
            return NotificationData(id: notification.objectId,
                                    type: .productFavorite(product: product, user: user),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        let data = UserDetailData.id(userId: user.id, source: .notifications)
                                        self?.navigator?.openUser(data)
                                    })
        case let .sold(product, _):
            return NotificationData(id: notification.objectId,
                                    type: .productSold(productImage: product.image), date: notification.createdAt,
                                    isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        let data = ListingDetailData.id(listingId: product.id)
                                        self?.navigator?.openListing(data, source: .notifications,
                                                                     showKeyboardOnFirstAppearIfNeeded: false)
                                    })
        case let .buyersInterested(product, buyers):
            var data = NotificationData(id: notification.objectId,
                                    type: .buyersInterested(product: product, buyers: buyers),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: nil,
                                    primaryActionCompleted: false)
            data.primaryAction = { [weak self] in
                self?.navigator?.openPassiveBuyers(product.id, actionCompletedBlock: { [weak self] in
                    self?.markCompleted(data)
                })
            }
            return data
        case let .productSuggested(product, seller):
            return NotificationData(id: notification.objectId,
                                    type: .productSuggested(product: product, seller: seller),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        let data = ListingDetailData.id(listingId: product.id)
                                        self?.navigator?.openListing(data, source: .notifications,
                                                                     showKeyboardOnFirstAppearIfNeeded: true)
                                    })
        case let .facebookFriendshipCreated(user, facebookUsername):
            return NotificationData(id: notification.objectId,
                                    type: .facebookFriendshipCreated(user: user, facebookUsername: facebookUsername),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        let data = UserDetailData.id(userId: user.id, source: .notifications)
                                        self?.navigator?.openUser(data)
            })
        case let .modular(modules):
            return NotificationData(id: notification.objectId,
                                    type: .modular(modules: modules, delegate: self),
                                    date: notification.createdAt, isRead: notification.isRead,
                                    campaignType: notification.campaignType,
                                    primaryAction: { [weak self] in
                                        guard let deeplink = modules.callToActions.first?.deeplink else { return }
                                        self?.triggerModularNotificationDeeplink(deeplink: deeplink)
                                    })
        }
    }

    func buildWelcomeNotification() -> NotificationData {
        return NotificationData(id: nil, type: .welcome(city: locationManager.currentLocation?.postalAddress?.city),
                                date: Date(), isRead: true, campaignType: nil, primaryAction: { [weak self] in
                                    self?.navigator?.openSell(.notifications)
                                })
    }
}


// MARK: - modularNotificationCellDelegate

extension NotificationsViewModel: ModularNotificationCellDelegate {
    func triggerModularNotificationDeeplink(deeplink: String) {
        guard let deepLinkURL = URL(string: deeplink) else { return }
        guard let deepLink = UriScheme.buildFromUrl(deepLinkURL)?.deepLink else { return }
        navigator?.openNotificationDeepLink(deepLink: deepLink)
    }
}


// MARK: - Trackings

fileprivate extension NotificationsViewModel {
    func trackVisit() {
        let event = TrackerEvent.notificationCenterStart()
        tracker.trackEvent(event)
    }

    func trackItemPressed(_ type: EventParameterNotificationType) {
        let event = TrackerEvent.notificationCenterComplete(type)
        tracker.trackEvent(event)
    }
    
    func trackErrorStateShown(reason: EventParameterEmptyReason) {
        let event = TrackerEvent.emptyStateVisit(typePage: .notifications, reason: reason)
        tracker.trackEvent(event)
    }
}

fileprivate extension NotificationDataType {
    var eventType: EventParameterNotificationType {
        switch self {
        case .productSold:
            return .productSold
        case .productFavorite:
            return .favorite
        case .rating:
            return .rating
        case .ratingUpdated:
            return .ratingUpdated
        case .welcome:
            return .welcome
        case .buyersInterested:
            return .buyersInterested
        case .productSuggested:
            return .productSuggested
        case .facebookFriendshipCreated:
            return .facebookFriendshipCreated
        case .modular:
            return .modular
        }
    }
}
