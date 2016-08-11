//
//  TabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol TabCoordinatorDelegate: class {
    func tabCoordinator(tabCoordinator: TabCoordinator, setSellButtonHidden hidden: Bool, animated: Bool)
}

class TabCoordinator: NSObject {
    var child: Coordinator?

    let rootViewController: UIViewController
    let navigationController: UINavigationController

    let productRepository: ProductRepository
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    let oldChatRepository: OldChatRepository
    let myUserRepository: MyUserRepository
    let keyValueStorage: KeyValueStorage
    let tracker: Tracker

    let disposeBag = DisposeBag()

    weak var tabCoordinatorDelegate: TabCoordinatorDelegate?


    // MARK: - Lifecycle

    init(productRepository: ProductRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         oldChatRepository: OldChatRepository, myUserRepository: MyUserRepository,
         keyValueStorage: KeyValueStorage, tracker: Tracker, rootViewController: UIViewController) {
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.myUserRepository = myUserRepository
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
    func openUser(data: UserDetailData) {
        switch data {
        case let .Id(userId, source):
            openUser(userId: userId, source: source)
        case let .UserAPI(user, source):
            openUser(user: user, source: source)
        case let .UserChat(user):
            openUser(user)
        }
    }

    func openProduct(data: ProductDetailData) {
        switch data {
        case let .Id(productId):
            openProduct(productId: productId)
        case let .ProductAPI(product, thumbnailImage, originFrame):
            openProduct(product: product, thumbnailImage: thumbnailImage, originFrame: originFrame)
        case let .ProductList(product, cellModels, requester, thumbnailImage, originFrame, showRelated):
            openProduct(product, cellModels: cellModels, requester: requester,
                        thumbnailImage: thumbnailImage, originFrame: originFrame, showRelated: showRelated)
        case let .ProductChat(chatProduct, user, thumbnailImage, originFrame):
            openProduct(chatProduct: chatProduct, user: user, thumbnailImage: thumbnailImage, originFrame: originFrame)
        }
    }
    
    func openExpressChat(products: [Product], sourceProductId: String) {
        guard let expressChatCoordinator = ExpressChatCoordinator(products: products, sourceProductId: sourceProductId) else { return }
        expressChatCoordinator.delegate = self
        openCoordinator(coordinator: expressChatCoordinator, parent: rootViewController, animated: true, completion: nil)
    }
}

private extension TabCoordinator {
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

    func openProduct(product product: Product, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil) {
        guard let vc = ProductDetailFactory.productDetailFromProduct(product, thumbnailImage: thumbnailImage,
                                                                     originFrame: originFrame,
                                                                     tabNavigator: self) else { return }
        navigationController.pushViewController(vc, animated: true)
    }


    func openProduct(product: Product, cellModels: [ProductCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool) {
        let vc: UIViewController?
        if showRelated {
            vc = ProductDetailFactory.productDetailFromProduct(product, thumbnailImage: thumbnailImage,
                                                               originFrame: originFrame, tabNavigator: self)
        } else {
            vc = ProductDetailFactory.productDetailFromProductListModels(cellModels, requester: requester,
                                                                         product: product,
                                                                         thumbnailImage: thumbnailImage,
                                                                         tabNavigator: self)
        }
        if let vc = vc {
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func openProduct(chatProduct chatProduct: ChatProduct, user: ChatInterlocutor,
                                 thumbnailImage: UIImage?, originFrame: CGRect?) {
        guard let productId = chatProduct.objectId else { return }
        let requester = RelatedProductListRequester(productId: productId)
        let vm = ProductCarouselViewModel(chatProduct: chatProduct, chatInterlocutor: user,
                                          thumbnailImage: thumbnailImage, productListRequester: requester,
                                          tabNavigator: self)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage)
        let vc = ProductCarouselViewController(viewModel: vm, pushAnimator: animator)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(userId userId: String, source: UserSource) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId, includeAccounts: false) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user, source: source)
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

    func openUser(user user: User, source: UserSource) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }

        let vm = UserViewModel(user: user, source: source)
        vm.tabNavigator = self
        let hidesBottomBarWhenPushed = navigationController.viewControllers.count == 1
        let vc = UserViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }


    func openUser(interlocutor: ChatInterlocutor) {
        let vm = UserViewModel(chatInterlocutor: interlocutor, source: .Chat)
        vm.tabNavigator = self

        let hidesBottomBarWhenPushed = navigationController.viewControllers.count == 1
        let vc = UserViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }

    func openCoordinator(coordinator coordinator: Coordinator, parent: UIViewController, animated: Bool,
                                     completion: (() -> Void)?) {
        guard child == nil else { return }
        child = coordinator
        coordinator.open(parent: parent, animated: animated, completion: completion)
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
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: false)
    }

    func navigationController(navigationController: UINavigationController,
                              didShowViewController viewController: UIViewController, animated: Bool) {
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: true)
    }

    func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return !viewController.isRootViewController()
    }
}


// MARK: - CoordinatorDelegate

extension TabCoordinator: CoordinatorDelegate {
    func coordinatorDidClose(coordinator: Coordinator) {
        child = nil
    }
}


// MARK: - ExpressChatCoordinatorDelegate

extension TabCoordinator: ExpressChatCoordinatorDelegate {
    func expressChatCoordinatorDidSentMessages(coordinator: ExpressChatCoordinator, count: Int) {
        let message = count == 1 ? LGLocalizedString.chatExpressOneMessageSentSuccessAlert :
            LGLocalizedString.chatExpressSeveralMessagesSentSuccessAlert
        rootViewController.showAutoFadingOutMessageAlert(message)
    }
}
