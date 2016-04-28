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

}


class NotificationsViewModel: BaseViewModel {

    weak var delegate: NotificationsViewModelDelegate?

    let viewState = Variable<ViewState>(.FirstLoad)

    private var notificationsData: [NotificationData] = []

    private let notificationsRepository: NotificationsRepository

    convenience override init() {
        self.init(notificationsRepository: Core.notificationsRepository)
    }

    init(notificationsRepository: NotificationsRepository) {
        self.notificationsRepository = notificationsRepository
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


    // MARK: - Private methods

    private func reloadNotifications() {
        notificationsRepository.index { [weak self] result in
            guard let strongSelf = self else { return }
            if let notifications = result.value {
                if notifications.count > 0 {
                    strongSelf.notificationsData = notifications.flatMap{ strongSelf.buildNotification($0) }
                } else {
                    strongSelf.notificationsData = [strongSelf.buildWelcomeNotification()]
                }
                strongSelf.viewState.value = .Data
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
            let dataType = NotificationDataType.ProductLike(title: "\(productTitle)", action: "asdf")
            return buildProductNotification(dataType, productId: productId, productImage: productImageUrl,
                                            userId: userId, userImage: userImageUrl, date: notification.createdAt,
                                            isRead: notification.isRead)
        case let .Sold(productId, productImageUrl, productTitle, userId, userImageUrl, userName):
            let dataType = NotificationDataType.ProductSold(title: "\(productTitle)", action: "asdf")
            return buildProductNotification(dataType, productId: productId, productImage: productImageUrl,
                                            userId: userId, userImage: userImageUrl, date: notification.createdAt,
                                            isRead: notification.isRead)
        }
    }

    private func buildProductNotification(type: NotificationDataType, productId: String, productImage: String?,
                                          userId: String, userImage: String?, date: NSDate, isRead: Bool) -> NotificationData {
        //TODO: IMPLEMENT
        return NotificationData(type: type, date: date, isRead: isRead, primaryAction: {})
    }

    private func buildWelcomeNotification() -> NotificationData {
        //TODO: IMPLEMENT
        return NotificationData(type: .News(title: "", subtitle: ""), date: NSDate(), isRead: true, primaryAction: {})
    }
}
