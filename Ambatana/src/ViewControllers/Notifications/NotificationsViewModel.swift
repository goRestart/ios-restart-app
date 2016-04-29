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

    let viewState = Variable<ViewState>(.Loading)

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
            let fakeResult = strongSelf.fakeNotifications()
            if let notifications = fakeResult.value {
                strongSelf.notificationsData = notifications.flatMap{ strongSelf.buildNotification($0) }
                if notifications.isEmpty {
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
                    action: { [weak self] in self?.reloadNotifications() })
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
            return buildProductNotification({ [weak self] in self?.openUser(userId) }, subtitle: subtitle,
                                            userName: userName, icon: icon, productId: productId,
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
            return buildProductNotification({ [weak self] in self?.openProduct(productId) }, subtitle: subtitle,
                                            userName: userName, icon: icon, productId: productId,
                                            productImage: productImageUrl, userId: userId, userImage: userImageUrl,
                                            date: notification.createdAt, isRead: notification.isRead)
        }
    }

    private func buildProductNotification(primaryAction: ()->Void, subtitle: String, userName: String?, icon: UIImage?,
                                          productId: String, productImage: String?, userId: String, userImage: String?,
                                          date: NSDate, isRead: Bool) -> NotificationData {
        let title: String
        if let userName = userName where !userName.isEmpty {
            title = userName
        } else {
            title = LGLocalizedString.notificationsUserWoName
        }
        return NotificationData(title: title, subtitle: subtitle, date: date, isRead: isRead,
                                primaryAction: primaryAction, icon: icon,
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


    // TODO: JUST TO TEST!! REMOVE!!
    private func fakeNotifications() -> ResultResult<[Notification], RepositoryError>.t {
        let productId = "9fc19de9-c48d-4c16-b651-b2062ebc04ea"
        let productImage = "http://cdn.stg.letgo.com/images/a2/d5/77/c5/a2d577c5d4324eb92a42c96b0274ac68.jpg"
        let userId = "f1e7adba-0647-4286-accf-141335758161"
        let userImage = "https://s3.amazonaws.com/letgo-avatars-stg/images/f0/fd/47/cd/f0fd47cdf56115aee0931543d7ebf45abfe1c960dbd5966d1084c3c80bd4c19f.jpg"
        var notifications: [Notification] = []
        notifications.append(FakeNotification(objectId: "1234", createdAt: NSDate(), isRead: true,
            type: .Sold(productId: productId, productImageUrl: productImage, productTitle: "Cacota", userId: userId, userImageUrl: userImage, userName: "Pepito")))
        notifications.append(FakeNotification(objectId: "1234", createdAt: NSDate(), isRead: true,
            type: .Like(productId: productId, productImageUrl: productImage, productTitle: "UUU flipa", userId: userId, userImageUrl: userImage, userName: "Juna palomo")))
        notifications.append(FakeNotification(objectId: "1234", createdAt: NSDate(), isRead: true,
            type: .Sold(productId: productId, productImageUrl: productImage, productTitle: "Caga tio", userId: userId, userImageUrl: userImage, userName: "Arturo")))
        return ResultResult<[Notification], RepositoryError>.t(value: notifications)
    }
}


private struct FakeNotification: Notification {
    let objectId: String?
    let createdAt: NSDate
    let isRead: Bool
    let type: NotificationType
}
