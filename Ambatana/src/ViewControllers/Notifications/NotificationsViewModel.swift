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

    private var pendingCountersUpdate = false

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  productRepository: Core.productRepository,
                  userRepository: Core.userRepository,
                  notificationsManager: NotificationsManager.sharedInstance,
                  locationManager: Core.locationManager)
    }

    init(notificationsRepository: NotificationsRepository, productRepository: ProductRepository,
         userRepository: UserRepository, notificationsManager: NotificationsManager, locationManager: LocationManager) {
        self.notificationsRepository = notificationsRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.notificationsManager = notificationsManager
        self.locationManager = locationManager

        super.init()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

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
                    strongSelf.markAsReadIfNeeded(notifications)
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

    private func buildNotification(notification: Notification) -> NotificationData? {
        switch notification.type {
        case .Follow: //Follow notifications not implemented yet
            return nil
        case let .Like(productId, productImageUrl, productTitle, userId, userImageUrl, userName):
            let subtitle: String
            if let productTitle = productTitle where !productTitle.isEmpty {
                subtitle = LGLocalizedString.notificationsTypeLikeWTitle(productTitle)
            } else {
                subtitle = LGLocalizedString.notificationsTypeLike
            }
            let icon = UIImage(named: "ic_favorite")
            return buildProductNotification({ [weak self] in
                let data = UserDetailData.Id(userId: userId, source: .Notifications)
                self?.tabNavigator?.openUser(data)
            }, subtitle: subtitle, userName: userName, icon: icon, productId: productId,
               productImage: productImageUrl, userId: userId, userImage: userImageUrl,
               date: notification.createdAt, isRead: notification.isRead)

        case let .Sold(productId, productImageUrl, productTitle, userId, userImageUrl, userName):
            let subtitle: String
            if let productTitle = productTitle where !productTitle.isEmpty {
                subtitle = LGLocalizedString.notificationsTypeSoldWTitle(productTitle)
            } else {
                subtitle = LGLocalizedString.notificationsTypeSold
            }
            let icon = UIImage(named: "ic_dollar_sold")
            return buildProductNotification({ [weak self] in
                let data = ProductDetailData.Id(productId: productId)
                self?.tabNavigator?.openProduct(data, source: .Notifications)
            }, subtitle: subtitle, userName: userName, icon: icon, productId: productId,
               productImage: productImageUrl, userId: userId, userImage: userImageUrl,
               date: notification.createdAt, isRead: notification.isRead)
        }
    }

    private func buildProductNotification(primaryAction: () -> Void, subtitle: String, userName: String?, icon: UIImage?,
                                          productId: String, productImage: String?, userId: String, userImage: String?,
                                          date: NSDate, isRead: Bool) -> NotificationData {
        let title: String
        if let userName = userName where !userName.isEmpty {
            title = userName
        } else {
            title = LGLocalizedString.notificationsUserWoName
        }
        let userImagePlaceholder = LetgoAvatar.avatarWithID(userId, name: userName)
        return NotificationData(type: .Product, title: title, subtitle: subtitle, date: date, isRead: isRead,
                                primaryAction: primaryAction, icon: icon,
                                leftImage: userImage, leftImagePlaceholder: userImagePlaceholder,
                                leftImageAction: { [weak self] in
                                    let data = UserDetailData.Id(userId: userId, source: .Notifications)
                                    self?.tabNavigator?.openUser(data) },
                                rightImage: productImage, rightImageAction: { [weak self] in
                                    let data = ProductDetailData.Id(productId: productId)
                                    self?.tabNavigator?.openProduct(data, source: .Notifications) })
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
                                primaryAction: { [weak self] in self?.delegate?.vmOpenSell() })
    }

    private func markAsReadIfNeeded(notifications: [Notification]) {
        let ids: [String] = notifications.flatMap{
            $0.isRead ? nil : $0.objectId
        }
        guard !ids.isEmpty else { return }
        notificationsRepository.markAsRead(ids) { [weak self] result in
            guard let strongSelf = self, let _ = result.value where !strongSelf.pendingCountersUpdate else { return }
            strongSelf.pendingCountersUpdate = true
        }
    }
}
