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
    func vmOpenUser(viewModel: UserViewModel)
    func vmOpenProduct(vc: UIViewController)
}


class NotificationsViewModel: BaseViewModel {

    weak var delegate: NotificationsViewModelDelegate?

    let viewState = Variable<ViewState>(.FirstLoad)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let locationManager: LocationManager

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository,
                  productRepository: Core.productRepository,
                  userRepository: Core.userRepository,
                  locationManager: Core.locationManager)
    }

    init(notificationsRepository: NotificationsRepository, productRepository: ProductRepository,
         userRepository: UserRepository, locationManager: LocationManager) {
        self.notificationsRepository = notificationsRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.locationManager = locationManager
        super.init()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

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


    // MARK: - Private methods

    private func reloadNotifications() {
        notificationsRepository.index { [weak self] result in
            guard let strongSelf = self else { return }
            if let notifications = result.value {
                strongSelf.notificationsData = notifications.flatMap{ strongSelf.buildNotification($0) }
                if notifications.isEmpty {
                    let emptyData = ViewErrorData(image: UIImage(named: "ic_notifications_empty" ),
                        title: LGLocalizedString.notificationsEmptyTitle,
                        body: LGLocalizedString.notificationsEmptySubtitle, buttonTitle: LGLocalizedString.tabBarToolTip,
                        buttonAction: { [weak self] in self?.delegate?.vmOpenSell() })
                    strongSelf.viewState.value = .Error(data: emptyData)
                } else {
                    strongSelf.viewState.value = .Data
                    strongSelf.markAsReadIfNeeded(notifications)
                }
            } else if let error = result.error {
                let errorData = ViewErrorData(repositoryError: error,
                    retryAction: { [weak self] in self?.reloadNotifications() })
                strongSelf.viewState.value = .Error(data: errorData)
            }
        }
    }

    private func buildNotification(notification: Notification) -> NotificationData? {
        switch notification.type {
        case .Follow: //Follow notifications not implemented yet
            return nil
        case let .Like(productId, productImageUrl, productTitle, userId, userImageUrl, userName):
            let action: String
            if let productTitle = productTitle where !productTitle.isEmpty {
                action = LGLocalizedString.notificationsTypeLikeWTitle(productTitle)
            } else {
                action = LGLocalizedString.notificationsTypeLike
            }
            let icon = UIImage(named: "ic_favorite")
            return buildProductNotification(action, userName: userName, icon: icon, productId: productId,
                                            productImage: productImageUrl, userId: userId, userImage: userImageUrl,
                                            date: notification.createdAt, isRead: notification.isRead)
        case let .Sold(productId, productImageUrl, productTitle, userId, userImageUrl, userName):
            let action: String
            if let productTitle = productTitle where !productTitle.isEmpty {
                action = LGLocalizedString.notificationsTypeSoldWTitle(productTitle)
            } else {
                action = LGLocalizedString.notificationsTypeSold
            }
            let icon = UIImage(named: "ic_dollar_sold")
            return buildProductNotification(action, userName: userName, icon: icon, productId: productId,
                                            productImage: productImageUrl, userId: userId, userImage: userImageUrl,
                                            date: notification.createdAt, isRead: notification.isRead)
        }
    }

    private func buildProductNotification(subtitle: String, userName: String?, icon: UIImage?, productId: String, productImage: String?,
                                          userId: String, userImage: String?, date: NSDate, isRead: Bool) -> NotificationData {
        let title: String
        if let userName = userName where !userName.isEmpty {
            title = userName
        } else {
            title = LGLocalizedString.notificationsUserWoName
        }
        return NotificationData(title: title, subtitle: subtitle, date: date, isRead: isRead,
                                primaryAction: { [weak self] in self?.openUser(userId) },
                                icon: icon,
                                leftImage: userImage, leftImageAction: { [weak self] in self?.openUser(userId) },
                                rightImage: productImage, rightImageAction: { [weak self] in self?.openProduct(productId) })
    }

    private func openUser(userId: String) {
        //TODO: CONSIDER USING APPCOORDINATOR WHEN MERGED
        delegate?.vmShowLoading(nil)
        userRepository.show(userId, includeAccounts: false) { [weak self] result in
            if let user = result.value {
                self?.delegate?.vmHideLoading(nil) {
                    let userVM = UserViewModel(user: user, source: .Notifications)
                    self?.delegate?.vmOpenUser(userVM)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .Forbidden, .NotFound, .Unauthorized:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    private func openProduct(productId: String) {
        //TODO: CONSIDER USING APPCOORDINATOR WHEN MERGED
        delegate?.vmShowLoading(nil)
        productRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.delegate?.vmHideLoading(nil) { [weak self] in
                    guard let productVC = ProductDetailFactory.productDetailFromProduct(product) else { return }
                    self?.delegate?.vmOpenProduct(productVC)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .Forbidden, .NotFound, .Unauthorized:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    private func markAsReadIfNeeded(notifications: [Notification]) {
        let allRead: Bool = notifications.reduce(true, combine: { $0 && $1.isRead })
        guard !allRead else { return }
        notificationsRepository.markAllAsRead(nil)
    }
}
