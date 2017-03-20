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
    func tabCoordinator(_ tabCoordinator: TabCoordinator, setSellButtonHidden hidden: Bool, animated: Bool)
}

class TabCoordinator: NSObject, Coordinator {
    var child: Coordinator?
    var viewController: UIViewController {
        return navigationController
    }
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    var bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    let rootViewController: UIViewController
    let navigationController: UINavigationController

    let listingRepository: ListingRepository
    let userRepository: UserRepository
    let chatRepository: ChatRepository
    let oldChatRepository: OldChatRepository
    let myUserRepository: MyUserRepository
    let keyValueStorage: KeyValueStorage
    let tracker: Tracker
    let featureFlags: FeatureFlaggeable
    let disposeBag = DisposeBag()

    var selectBuyerToRateCompletion: ((String?) -> Void)?

    weak var tabCoordinatorDelegate: TabCoordinatorDelegate?
    weak var appNavigator: AppNavigator?


    // MARK: - Lifecycle

    init(listingRepository: ListingRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         oldChatRepository: OldChatRepository, myUserRepository: MyUserRepository,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage, tracker: Tracker, rootViewController: UIViewController,
         featureFlags: FeatureFlaggeable, sessionManager: SessionManager) {
        self.listingRepository = listingRepository
        self.userRepository = userRepository
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.myUserRepository = myUserRepository
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.rootViewController = rootViewController
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        self.navigationController = UINavigationController(rootViewController: rootViewController)
        super.init()
        
        self.navigationController.delegate = self
    }


    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {}
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {}

    func isShowingConversation(_ data: ConversationData) -> Bool {
        if let convDataDisplayer = navigationController.viewControllers.last as? ConversationDataDisplayer {
            return convDataDisplayer.isDisplayingConversationData(data)
        }
        return false
    }

    func shouldHideSellButtonAtViewController(_ viewController: UIViewController) -> Bool {
        return !viewController.isRootViewController()
    }
}


// MARK: - TabNavigator

extension TabCoordinator: TabNavigator {

    func openSell(_ source: PostingSource) {
        appNavigator?.openSell(source)
    }

    func openUser(_ data: UserDetailData) {
        switch data {
        case let .id(userId, source):
            openUser(userId: userId, source: source)
        case let .userAPI(user, source):
            openUser(user: user, source: source)
        case let .userChat(user):
            openUser(user)
        }
    }

    func openProduct(_ data: ProductDetailData, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {
        switch data {
        case let .id(productId):
            openProduct(productId: productId, source: source,
                        showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded)
        case let .productAPI(product, thumbnailImage, originFrame):
            openProduct(product: product, thumbnailImage: thumbnailImage, originFrame: originFrame, source: source,
                        index: 0, discover: false, showKeyboardOnFirstAppearIfNeeded: false)
        case let .productList(product, cellModels, requester, thumbnailImage, originFrame, showRelated, index):
            openProduct(product, cellModels: cellModels, requester: requester, thumbnailImage: thumbnailImage,
                        originFrame: originFrame, showRelated: showRelated, source: source,
                        index: index)
        case let .productChat(chatConversation):
            openProduct(chatConversation: chatConversation, source: source)
        }
    }

    func openChat(_ data: ChatDetailData, source: EventParameterTypePage) {
        switch data {
        case let .chatAPI(chat):
            openChat(chat, source: source)
        case let .conversation(conversation):
            openConversation(conversation, source: source)
        case let .productAPI(product):
            openProductChat(product)
        case let .dataIds(data):
            openChatFromConversationData(data, source: source)
        }
    }

    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        appNavigator?.openVerifyAccounts(types, source: source, completionBlock: completionBlock)
    }
    
    func openAppInvite() {
        appNavigator?.openAppInvite()
    }

    func canOpenAppInvite() -> Bool {
        return appNavigator?.canOpenAppInvite() ?? false
    }

    func openRatingList(_ userId: String) {
        let vm = UserRatingListViewModel(userId: userId, tabNavigator: self)
        let vc = UserRatingListViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openDeepLink(_ deeplink: DeepLink) {
        appNavigator?.openDeepLink(deepLink: deeplink)
    }

    var hidesBottomBarWhenPushed: Bool {
        return navigationController.viewControllers.count == 1
    }
}

fileprivate extension TabCoordinator {
    func openProduct(productId: String, source: EventParameterProductVisitSource,
                     showKeyboardOnFirstAppearIfNeeded: Bool) {
        navigationController.showLoadingMessageAlert()
        listingRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openProduct(product: product, source: source, index: 0, discover: false,
                                      showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                    self?.trackProductNotAvailable(source: source, repositoryError: error)
                }
            }
        }
    }

    func openProduct(product: Product, thumbnailImage: UIImage? = nil, originFrame: CGRect? = nil,
                             source: EventParameterProductVisitSource, requester: ProductListRequester? = nil, index: Int,
                             discover: Bool, showKeyboardOnFirstAppearIfNeeded: Bool) {
        guard let productId = product.objectId else { return }

        var requestersArray: [ProductListRequester] = []
        let relatedRequester: ProductListRequester = discover ?
            DiscoverProductListRequester(productId: productId, itemsPerPage: Constants.numProductsPerPageDefault) :
            RelatedProductListRequester(productId: productId, itemsPerPage: Constants.numProductsPerPageDefault)
        requestersArray.append(relatedRequester)

        // Adding product list after related
        let listOffset = index + 1 // we need the product AFTER the current one
        if let requester = requester {
            let requesterCopy = requester.duplicate()
            requesterCopy.updateInitialOffset(listOffset)
            requestersArray.append(requesterCopy)
        } else {
            let filteredRequester = FilteredProductListRequester(itemsPerPage: Constants.numProductsPerPageDefault, offset: listOffset)
            requestersArray.append(filteredRequester)
        }

        let requester = ProductListMultiRequester(requesters: requestersArray)

        let vm = ProductCarouselViewModel(product: product, thumbnailImage: thumbnailImage,
                                          productListRequester: requester, source: source,
                                          showKeyboardOnFirstAppearIfNeeded: showKeyboardOnFirstAppearIfNeeded, trackingIndex: index)
        vm.navigator = self
        openProduct(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, productId: product.objectId)
    }

    func openProduct(_ product: Product, cellModels: [ProductCellModel], requester: ProductListRequester,
                     thumbnailImage: UIImage?, originFrame: CGRect?, showRelated: Bool,
                     source: EventParameterProductVisitSource, index: Int) {
        if showRelated {
            //Same as single product opening
            let discover = !featureFlags.productDetailNextRelated
            openProduct(product: product, thumbnailImage: thumbnailImage, originFrame: originFrame,
                        source: source, requester: requester, index: index, discover: discover,
                        showKeyboardOnFirstAppearIfNeeded: false)
        } else {
            let vm = ProductCarouselViewModel(productListModels: cellModels, initialProduct: product,
                                              thumbnailImage: thumbnailImage, productListRequester: requester, source: source,
                                              showKeyboardOnFirstAppearIfNeeded: false, trackingIndex: index,
                                              firstProductSyncRequired: false)
            vm.navigator = self
            openProduct(vm, thumbnailImage: thumbnailImage, originFrame: originFrame, productId: product.objectId)
        }
    }

    func openProduct(chatConversation: ChatConversation, source: EventParameterProductVisitSource) {
        guard let localProduct = LocalProduct(chatConversation: chatConversation, myUser: myUserRepository.myUser),
            let productId = localProduct.objectId else { return }
        let relatedRequester = RelatedProductListRequester(productId: productId,  itemsPerPage: Constants.numProductsPerPageDefault)
        let filteredRequester = FilteredProductListRequester( itemsPerPage: Constants.numProductsPerPageDefault, offset: 0)
        let requester = ProductListMultiRequester(requesters: [relatedRequester, filteredRequester])
        let vm = ProductCarouselViewModel(product: localProduct, productListRequester: requester,
                                          source: source, showKeyboardOnFirstAppearIfNeeded: false, trackingIndex: nil)
        vm.navigator = self
        openProduct(vm, thumbnailImage: nil, originFrame: nil, productId: productId)
    }

    func openProduct(_ viewModel: ProductCarouselViewModel, thumbnailImage: UIImage?, originFrame: CGRect?,
                     productId: String?) {
        let color = UIColor.placeholderBackgroundColor(productId)
        let animator = ProductCarouselPushAnimator(originFrame: originFrame, originThumbnail: thumbnailImage,
                                                   backgroundColor: color)
        let vc = ProductCarouselViewController(viewModel: viewModel, pushAnimator: animator)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(userId: String, source: UserSource) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user, source: source)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func openUser(user: User, source: UserSource) {
        // If it's me do not then open the user profile
        guard myUserRepository.myUser?.objectId != user.objectId else { return }

        let vm = UserViewModel(user: user, source: source)
        vm.navigator = self
        let vc = UserViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }


    func openUser(_ interlocutor: ChatInterlocutor) {
        let vm = UserViewModel(chatInterlocutor: interlocutor, source: .chat)
        vm.navigator = self
        let vc = UserViewController(viewModel: vm, hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navigationController.pushViewController(vc, animated: true)
    }

    func openChat(_ chat: Chat, source: EventParameterTypePage) {
        guard let vm = OldChatViewModel(chat: chat, navigator: self, source: source) else { return }
        let vc = OldChatViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openConversation(_ conversation: ChatConversation, source: EventParameterTypePage) {
        let vm = ChatViewModel(conversation: conversation, navigator: self, source: source)
        let vc = ChatViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openChatFromProduct(_ product: Product) {
        if featureFlags.websocketChat {
            guard let chatVM = ChatViewModel(product: product, navigator: self, source: .productDetail) else { return }
            let chatVC = ChatViewController(viewModel: chatVM, hidesBottomBar: false)
            navigationController.pushViewController(chatVC, animated: true)
        } else {
            guard let chatVM = OldChatViewModel(product: product, navigator: self, source: .productDetail) else { return }
            let chatVC = OldChatViewController(viewModel: chatVM, hidesBottomBar: false)
            navigationController.pushViewController(chatVC, animated: true)
        }
    }

    func openChatFromConversationData(_ data: ConversationData, source: EventParameterTypePage) {
        navigationController.showLoadingMessageAlert()

        if featureFlags.websocketChat {
            let completion: ChatConversationCompletion = { [weak self] result in
                self?.navigationController.dismissLoadingMessageAlert { [weak self] in
                    if let conversation = result.value {
                        self?.openConversation(conversation, source: source)
                    } else if let error = result.error {
                        self?.showChatRetrieveError(error)
                    }
                }
            }
            switch data {
            case let .conversation(conversationId):
                chatRepository.showConversation(conversationId, completion: completion)
            case .productBuyer:
                return //Those are the legacy pushes and new chat doesn't work with Product + buyer
            }
        } else {
            let completion: ChatCompletion = { [weak self] result in
                self?.navigationController.dismissLoadingMessageAlert { [weak self] in
                    if let chat = result.value {
                        self?.openChat(chat, source: source)
                    } else if let error = result.error {
                        self?.showChatRetrieveError(error)
                    }
                }
            }
            switch data {
            case let .conversation(conversationId):
                oldChatRepository.retrieveMessagesWithConversationId(conversationId, page: 0,
                                                    numResults: Constants.numMessagesPerPage, completion: completion)
            case let .productBuyer(productId, buyerId):
                oldChatRepository.retrieveMessagesWithProductId(productId, buyerId: buyerId, page: 0,
                                                    numResults: Constants.numMessagesPerPage, completion: completion)
            }
        }
    }

    func showChatRetrieveError(_ error: RepositoryError) {
        let message: String
        switch error {
        case .network:
            message = LGLocalizedString.commonErrorConnectionFailed
        case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
            message = LGLocalizedString.commonChatNotAvailable
        }
        navigationController.showAutoFadingOutMessageAlert(message)
    }
}


// MARK: > ProductDetailNavigator

extension TabCoordinator: ProductDetailNavigator {
    func closeProductDetail() {
        navigationController.popViewController(animated: true)
    }

    func editProduct(_ product: Product) {
        // TODO: Open EditProductCoordinator
        let editProductVM = EditProductViewModel(product: product)
        let editProductVC = EditProductViewController(viewModel: editProductVM)
        let navCtl = UINavigationController(rootViewController: editProductVC)
        navigationController.present(navCtl, animated: true, completion: nil)
    }

    func openProductChat(_ product: Product) {
        openChatFromProduct(product)
    }

    func closeAfterDelete() {
        closeProductDetail()
        let action = UIAction(interface: .button(LGLocalizedString.productDeletePostButtonTitle,
                                                 .primary(fontSize: .medium)), action: { [weak self] in
                                                    self?.openSell(.deleteProduct)
            }, accessibilityId: .postDeleteAlertButton)
        navigationController.showAlertWithTitle(LGLocalizedString.productDeletePostTitle,
                                                text: LGLocalizedString.productDeletePostSubtitle,
                                                alertType: .plainAlert, actions: [action])
    }

    func openFreeBumpUpForProduct(product: Product, socialMessage: SocialMessage, withPaymentItemId paymentItemId: String) {
        let bumpCoordinator = BumpUpCoordinator(product: product, socialMessage: socialMessage, paymentItemId: paymentItemId)
        openChild(coordinator: bumpCoordinator, parent: rootViewController, animated: true, completion: nil)
    }

    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct,
                                 withPaymentItemId paymentItemId: String) {
        let bumpCoordinator = BumpUpCoordinator(product: product, purchaseableProduct: purchaseableProduct,
                                                paymentItemId: paymentItemId)
//        bumpCoordinator.delegate = self
        openChild(coordinator: bumpCoordinator, parent: rootViewController, animated: true, completion: nil)
    }

    func selectBuyerToRate(source: RateUserSource, buyers: [UserProduct], completion: @escaping (String?) -> Void) {
        selectBuyerToRateCompletion = completion
        let ratingCoordinator = UserRatingCoordinator(source: source, buyers: buyers)
        ratingCoordinator.delegate = self
        openChild(coordinator: ratingCoordinator, parent: rootViewController, animated: true, completion: nil)
    }

    func showProductFavoriteBubble(with data: BubbleNotificationData) {
        showBubble(with: data, duration: Constants.bubbleFavoriteDuration)
    }

    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from, style: .popup(infoMessage), loggedInAction: loggedInAction)
    }
}


// MARK: SimpleProductsNavigator

extension TabCoordinator: SimpleProductsNavigator {
    func closeSimpleProducts() {
        navigationController.popViewController(animated: true)
    }
}


// MARK: > ChatDetailNavigator

extension TabCoordinator: ChatDetailNavigator {
    func closeChatDetail() {
        navigationController.popViewController(animated: true)
    }

    func openExpressChat(_ products: [Product], sourceProductId: String, manualOpen: Bool) {
        guard let expressChatCoordinator = ExpressChatCoordinator(products: products, sourceProductId: sourceProductId, manualOpen: manualOpen) else { return }
        expressChatCoordinator.delegate = self
        openChild(coordinator: expressChatCoordinator, parent: rootViewController, animated: true, completion: nil)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from, style: .popup(LGLocalizedString.chatLoginPopupText),
                          loggedInAction: loggedInAction)
    }
}


// MARK: - UINavigationControllerDelegate

extension TabCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                                  to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let animator = (toVC as? AnimatableTransition)?.animator, operation == .push {
            animator.pushing = true
            return animator
        } else if let animator = (fromVC as? AnimatableTransition)?.animator, operation == .pop {
            animator.pushing = false
            return animator
        } else {
            return nil
        }
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: false)
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController, animated: Bool) {
        tabCoordinatorDelegate?.tabCoordinator(self,
                                               setSellButtonHidden: shouldHideSellButtonAtViewController(viewController),
                                               animated: true)
    }
}


// MARK: - CoordinatorDelegate

extension TabCoordinator: CoordinatorDelegate {
    func coordinatorDidClose(_ coordinator: Coordinator) {
        child = nil
    }
}


// MARK: - ExpressChatCoordinatorDelegate

extension TabCoordinator: ExpressChatCoordinatorDelegate {
    func expressChatCoordinatorDidSentMessages(_ coordinator: ExpressChatCoordinator, count: Int) {
        let message = count == 1 ? LGLocalizedString.chatExpressOneMessageSentSuccessAlert :
            LGLocalizedString.chatExpressSeveralMessagesSentSuccessAlert
        rootViewController.showAutoFadingOutMessageAlert(message)
    }
}


// MARK: - UserRatingCoordinatorDelegate 

extension TabCoordinator: UserRatingCoordinatorDelegate {
    func userRatingCoordinatorDidCancel() {
        selectBuyerToRateCompletion = nil
    }

    func userRatingCoordinatorDidFinish(withRating rating: Int?, ratedUserId: String?) {
        selectBuyerToRateCompletion?(ratedUserId)
        selectBuyerToRateCompletion = nil
    }
}


// MARK: - Tracking

extension TabCoordinator {
    func trackProductNotAvailable(source: EventParameterProductVisitSource, repositoryError: RepositoryError) {
        var reason: EventParameterNotAvailableReason
        switch repositoryError {
        case .internalError:
            reason = .internalError
        case .notFound:
            reason = .notFound
        case .unauthorized:
            reason = .unauthorized
        case .forbidden:
            reason = .forbidden
        case .tooManyRequests:
            reason = .tooManyRequests
        case .userNotVerified:
            reason = .userNotVerified
        case .serverError:
            reason = .serverError
        case .network:
            reason = .network
        }
        let productNotAvailableEvent = TrackerEvent.productNotAvailable( source, reason: reason)
        tracker.trackEvent(productNotAvailableEvent)
    }
}
