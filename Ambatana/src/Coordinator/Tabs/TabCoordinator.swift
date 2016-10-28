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
    weak var appNavigator: AppNavigator?

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

    func isShowingConversation(data: ConversationData) -> Bool {
        if let convDataDisplayer = navigationController.viewControllers.last as? ConversationDataDisplayer {
            return convDataDisplayer.isDisplayingConversationData(data)
        }
        return false
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

    func openProduct(data: ProductDetailData, source: EventParameterProductVisitSource) {
        switch data {
        case let .Id(productId):
            openProduct(productId: productId, source: source)
        case let .ProductAPI(product, thumbnailImage, originFrame):
            openProduct(product: product, thumbnailImage: thumbnailImage, originFrame: originFrame, source: source,
                        index: 0, discover: false)
        case let .ProductList(product, cellModels, requester, thumbnailImage, originFrame, showRelated, index):
            openProduct(product, cellModels: cellModels, requester: requester, thumbnailImage: thumbnailImage,
                        originFrame: originFrame, showRelated: showRelated, source: source,
                        index: index)
        case let .ProductChat(chatProduct, user, thumbnailImage, originFrame):
            openProduct(chatProduct: chatProduct, user: user, thumbnailImage: thumbnailImage, originFrame: originFrame,
                        source: source)
        }
    }

    func openChat(data: ChatDetailData) {
        switch data {
        case let .ChatAPI(chat):
            openChat(chat)
        case let .Conversation(conversation):
            openConversation(conversation)
        case let .ProductAPI(product):
            openProductChat(product)
        case let .DataIds(data):
            openChatFromConversationData(data)
        }
    }

    func openVerifyAccounts(types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        appNavigator?.openVerifyAccounts(types, source: source, completionBlock: completionBlock)
    }
    
    func openAppInvite() {
        appNavigator?.openAppInvite()
    }

    func canOpenAppInvite() -> Bool {
        return appNavigator?.canOpenAppInvite() ?? false
    }

    func openRatingList(userId: String) {
        let vm = UserRatingListViewModel(userId: userId, tabNavigator: self)
        let vc = UserRatingListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

private extension TabCoordinator {
    func openProduct(productId productId: String, source: EventParameterProductVisitSource) {
        navigationController.showLoadingMessageAlert()
        productRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openProduct(product: product, source: source, index: 0, discover: false)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func openProduct(product product: Product, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil,
                             source: EventParameterProductVisitSource, requester: ProductListRequester? = nil, index: Int,
                             discover: Bool) {
        guard let productId = product.objectId else { return }

        var requestersArray: [ProductListRequester] = []
        let relatedRequester: ProductListRequester = discover ? DiscoverProductListRequester(productId: productId) : RelatedProductListRequester(productId: productId)
        requestersArray.append(relatedRequester)

        if FeatureFlags.nonStopProductDetail {
            let listOffset = index + 1 // we need the product AFTER the current one
            if let requester = requester {
                let requesterCopy = requester.duplicate()
                requesterCopy.updateInitialOffset(listOffset)
                requestersArray.append(requesterCopy)
            } else {
                let filteredRequester = FilteredProductListRequester(offset: listOffset)
                requestersArray.append(filteredRequester)
            }
        }

        let requester = ProductListMultiRequester(requesters: requestersArray)

        let vm = ProductCarouselViewModel(product: product, thumbnailImage: thumbnailImage,
                                      productListRequester: requester, navigator: self, source: source)
        openProduct(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, productId: product.objectId)
    }

    func openProduct(product: Product, cellModels: [ProductCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool,
                     source: EventParameterProductVisitSource, index: Int) {
        if showRelated {
            //Same as single product opening
            openProduct(product: product, thumbnailImage: thumbnailImage, originFrame: originFrame,
                        source: source, requester: requester, index: index, discover: true)
        } else {
            let vm = ProductCarouselViewModel(productListModels: cellModels, initialProduct: product,
                                              thumbnailImage: thumbnailImage, productListRequester: requester,
                                              navigator: self, source: source)
            openProduct(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, productId: product.objectId)
        }

    }

    func openProduct(chatProduct chatProduct: ChatProduct, user: ChatInterlocutor, thumbnailImage: UIImage?,
                                 originFrame: CGRect?, source: EventParameterProductVisitSource) {
        guard let productId = chatProduct.objectId else { return }
        let relatedRequester = RelatedProductListRequester(productId: productId)
        let filteredRequester = FilteredProductListRequester(offset: 0)
        let requester = ProductListMultiRequester(requesters: [relatedRequester, filteredRequester])
        let vm = ProductCarouselViewModel(chatProduct: chatProduct, chatInterlocutor: user,
                                          thumbnailImage: thumbnailImage, productListRequester: requester,
                                          navigator: self, source: source)
        openProduct(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, productId: productId)
    }

    func openProduct(viewModel: ProductCarouselViewModel, thumbnailImage: UIImage?, originFrame: CGRect?,
                     productId: String?) {
        let color = UIColor.placeholderBackgroundColor(productId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        let vc = ProductCarouselViewController(viewModel: viewModel, pushAnimator: animator)
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
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
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

    func openChat(chat: Chat) {
        guard let vm = OldChatViewModel(chat: chat, navigator: self) else { return }
        let vc = OldChatViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openConversation(conversation: ChatConversation) {
        let vm = ChatViewModel(conversation: conversation, navigator: self)
        let vc = ChatViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openChatFromProduct(product: Product) {
        if FeatureFlags.websocketChat {
            guard let chatVM = ChatViewModel(product: product, navigator: self) else { return }
            let chatVC = ChatViewController(viewModel: chatVM, hidesBottomBar: false)
            navigationController.pushViewController(chatVC, animated: true)
        } else {
            guard let chatVM = OldChatViewModel(product: product, navigator: self) else { return }
            let chatVC = OldChatViewController(viewModel: chatVM, hidesBottomBar: false)
            navigationController.pushViewController(chatVC, animated: true)
        }
    }

    func openChatFromConversationData(data: ConversationData) {
        navigationController.showLoadingMessageAlert()

        if FeatureFlags.websocketChat {
            let completion: ChatConversationCompletion = { [weak self] result in
                self?.navigationController.dismissLoadingMessageAlert { [weak self] in
                    if let conversation = result.value {
                        self?.openConversation(conversation)
                    } else if let error = result.error {
                        self?.showChatRetrieveError(error)
                    }
                }
            }
            switch data {
            case let .Conversation(conversationId):
                chatRepository.showConversation(conversationId, completion: completion)
            case .ProductBuyer:
                return //Those are the legacy pushes and new chat doesn't work with Product + buyer
            }
        } else {
            let completion: ChatCompletion = { [weak self] result in
                self?.navigationController.dismissLoadingMessageAlert { [weak self] in
                    if let chat = result.value {
                        self?.openChat(chat)
                    } else if let error = result.error {
                        self?.showChatRetrieveError(error)
                    }
                }
            }
            switch data {
            case let .Conversation(conversationId):
                oldChatRepository.retrieveMessagesWithConversationId(conversationId,
                                                    numResults: Constants.numMessagesPerPage, completion: completion)
            case let .ProductBuyer(productId, buyerId):
                oldChatRepository.retrieveMessagesWithProductId(productId, buyerId: buyerId,
                                                    numResults: Constants.numMessagesPerPage, completion: completion)
            }
        }
    }

    func showChatRetrieveError(error: RepositoryError) {
        let message: String
        switch error {
        case .Network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
            message = LGLocalizedString.commonChatNotAvailable
        }
        navigationController.showAutoFadingOutMessageAlert(message)
    }

    func openCoordinator(coordinator coordinator: Coordinator, parent: UIViewController, animated: Bool,
                                     completion: (() -> Void)?) {
        guard child == nil else { return }
        child = coordinator
        coordinator.open(parent: parent, animated: animated, completion: completion)
    }
}


// MARK: > ProductDetailNavigator

extension TabCoordinator: ProductDetailNavigator {
    func closeProductDetail() {
        navigationController.popViewControllerAnimated(true)
    }

    func editProduct(product: Product, closeCompletion: ((Product?) -> Void)?) {
        // TODO: Open EditProductCoordinator, refactor this completion with a EditProductCoordinatorDelegate func
        let editProductVM = EditProductViewModel(product: product)
        editProductVM.closeCompletion = closeCompletion
        let editProductVC = EditProductViewController(viewModel: editProductVM)
        let navCtl = UINavigationController(rootViewController: editProductVC)
        navigationController.presentViewController(navCtl, animated: true, completion: nil)
    }

    func openProductChat(product: Product) {
        openChatFromProduct(product)
    }

    func openFullScreenShare(productVM: ProductViewModel) {
        let shareProductVM = ShareProductViewModel(productVM: productVM)
        let shareProductVC = ShareProductViewController(viewModel: shareProductVM)
        navigationController.presentViewController(shareProductVC, animated: true, completion: nil)
    }
}


// MARK: > ChatDetailNavigator

extension TabCoordinator: ChatDetailNavigator {
    func closeChatDetail() {
        navigationController.popViewControllerAnimated(true)
    }

    func openExpressChat(products: [Product], sourceProductId: String) {
        guard let expressChatCoordinator = ExpressChatCoordinator(products: products, sourceProductId: sourceProductId) else { return }
        expressChatCoordinator.delegate = self
        openCoordinator(coordinator: expressChatCoordinator, parent: rootViewController, animated: true, completion: nil)
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
