//
//  NotificationsTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class NotificationsTabCoordinator: TabCoordinator {

    let passiveBuyersRepository: PassiveBuyersRepository

    private var passsiveBuyersCompletion: (() -> Void)?

    convenience init() {
        let passiveBuyersRepository = Core.passiveBuyersRepository
        self.init(passiveBuyersRepository: passiveBuyersRepository)
    }

    init(passiveBuyersRepository: PassiveBuyersRepository) {
        self.passiveBuyersRepository = passiveBuyersRepository

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let bubbleNotificationManager = BubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = NotificationsViewModel()
        let featureFlags = FeatureFlags.sharedInstance
        let rootViewController = NotificationsViewController(viewModel: viewModel)
        super.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController, featureFlags: featureFlags)

        viewModel.navigator = self
    }

    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return true
    }
}


// MARK: - NotificationsTabNavigator

extension NotificationsTabCoordinator: NotificationsTabNavigator {
    func openMyRatingList() {
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        openRatingList(myUserId)
    }

    // TODO: remove actionCompletedBlock when status comes from back-end
    func openPassiveBuyers(productId: String, actionCompletedBlock: (() -> Void)?) {
        navigationController.showLoadingMessageAlert()
        passiveBuyersRepository.show(productId: productId) { [weak self] result in
            if let passiveBuyersInfo = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openPassiveBuyers(passiveBuyersInfo, actionCompletedBlock: actionCompletedBlock)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
                    message = LGLocalizedString.passiveBuyersNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    private func openPassiveBuyers(passiveBuyersInfo: PassiveBuyersInfo, actionCompletedBlock: (() -> Void)?) {
        passsiveBuyersCompletion = actionCompletedBlock

        let passiveBuyersCoordinator = PassiveBuyersCoordinator(passiveBuyersInfo: passiveBuyersInfo)
        passiveBuyersCoordinator.delegate = self
        openCoordinator(coordinator: passiveBuyersCoordinator, parent: rootViewController, animated: true, completion: nil)
    }
}


// MARK: - PassiveBuyersCoordinatorDelegate

extension NotificationsTabCoordinator: PassiveBuyersCoordinatorDelegate {
    func passiveBuyersCoordinatorDidCancel(coordinator: PassiveBuyersCoordinator) {
        passsiveBuyersCompletion = nil
    }

    func passiveBuyersCoordinatorDidFinish(coordinator: PassiveBuyersCoordinator) {
        passsiveBuyersCompletion?()
        passsiveBuyersCompletion = nil
    }
}
