//
//  TabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class TabCoordinator: NSObject {
    var child: Coordinator?

    let rootViewController: UIViewController
    let navigationController: UINavigationController

    let productRepository: ProductRepository
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    let oldChatRepository: OldChatRepository
    let keyValueStorage: KeyValueStorage
    let tracker: Tracker

    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(productRepository: ProductRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         oldChatRepository: OldChatRepository, keyValueStorage: KeyValueStorage, tracker: Tracker,
         rootViewController: UIViewController) {
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.rootViewController = rootViewController
        self.navigationController = UINavigationController(rootViewController: rootViewController)

        super.init()
        self.navigationController.delegate = self
    }
}


// MARK: - TabNavigator

extension TabCoordinator: TabNavigator {
    func openUser(user user: User) {
        let viewModel = UserViewModel(user: user, source: .TabBar)
        let vc = UserViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(userId userId: String) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId, includeAccounts: false) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func openProduct(product product: Product) {
        guard let vc = ProductDetailFactory.productDetailFromProduct(product) else { return }
        navigationController.pushViewController(vc, animated: true)
    }

    func openProduct(productId productId: String) {
        navigationController.showLoadingMessageAlert()
        productRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openProduct(product: product)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }
}


// MARK: - UINavigationControllerDelegate

extension TabCoordinator: UINavigationControllerDelegate {


    func navigationController(navigationController: UINavigationController,
                              animationControllerForOperation operation: UINavigationControllerOperation,
                              fromViewController fromVC: UIViewController,
                                  toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = (toVC as? AnimatableTransition)?.animator where operation == .Push {
            animator.pushing = true
            return animator
        } else if let animator = (fromVC as? AnimatableTransition)?.animator where operation == .Pop {
            animator.pushing = false
            return animator
        } else {
            return nil
        }
    }

    func navigationController(navigationController: UINavigationController,
                              willShowViewController viewController: UIViewController, animated: Bool) {
        // TODO: udpdate sell floating button
//        updateFloatingButtonFor(navigationController, presenting: viewController, animate: false)
    }

    func navigationController(navigationController: UINavigationController,
                              didShowViewController viewController: UIViewController, animated: Bool) {
//        updateFloatingButtonFor(navigationController, presenting: viewController, animate: true)
    }

//    private func updateFloatingButtonFor(navigationController: UINavigationController,
//                                         presenting viewController: UIViewController, animate: Bool) {
//        guard let viewControllers = viewControllers else { return }
//
//        let vcIdx = (viewControllers as NSArray).indexOfObject(navigationController)
//        if let tab = Tab(index: vcIdx) {
//            switch tab {
//            case .Home, .Categories, .Sell, .Profile:
//                //In case of those 4 sections, show if ctrl is root, or if its the MainProductsViewController
//                let showBtn = viewController.isRootViewController() || (viewController is MainProductsViewController)
//                setSellFloatingButtonHidden(!showBtn, animated: animate)
//            case .Chats, .Notifications:
//                setSellFloatingButtonHidden(true, animated: false)
//            }
//        }
//    }
}
