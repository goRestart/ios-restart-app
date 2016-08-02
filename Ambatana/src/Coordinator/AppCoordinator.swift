//
//  AppCoordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import FBSDKCoreKit
import LGCoreKit
import RxSwift
import UIKit

final class AppCoordinator: NSObject {
    var child: Coordinator?
    var presentedAlertController: UIAlertController?

    private let tabBarCtl: TabBarController

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let keyValueStorage: KeyValueStorage
    private let pushPermissionsManager: PushPermissionsManager
    private let ratingManager: RatingManager

    private let deepLinksRouter: DeepLinksRouter

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let chatRepository: OldChatRepository
    private let commercializerRepository: CommercializerRepository
    private let userRatingRepository: UserRatingRepository

    weak var delegate: AppNavigatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(tabBarController: TabBarController, configManager: ConfigManager) {
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let pushPermissionsManager = PushPermissionsManager.sharedInstance
        let ratingManager = RatingManager.sharedInstance
        let deepLinksRouter = DeepLinksRouter.sharedInstance

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.oldChatRepository
        let commercializerRepository = Core.commercializerRepository
        let userRatingRepository = Core.userRatingRepository

        self.init(tabBarController: tabBarController, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                  pushPermissionsManager: pushPermissionsManager, ratingManager: ratingManager,
                  deepLinksRouter: deepLinksRouter, productRepository: productRepository, userRepository: userRepository,
                  myUserRepository: myUserRepository, chatRepository: chatRepository,
                  commercializerRepository: commercializerRepository, userRatingRepository: userRatingRepository)
    }

    init(tabBarController: TabBarController, configManager: ConfigManager,
         sessionManager: SessionManager, keyValueStorage: KeyValueStorage,
         pushPermissionsManager: PushPermissionsManager, ratingManager: RatingManager, deepLinksRouter: DeepLinksRouter,
         productRepository: ProductRepository, userRepository: UserRepository, myUserRepository: MyUserRepository,
         chatRepository: OldChatRepository, commercializerRepository: CommercializerRepository,
         userRatingRepository: UserRatingRepository) {

        self.tabBarCtl = tabBarController

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager

        self.deepLinksRouter = deepLinksRouter

        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.commercializerRepository = commercializerRepository
        self.userRatingRepository = userRatingRepository

        super.init()
        tabBarCtl.delegate = self

        setupDeepLinkingRx()
        setupNotificationCenterObservers()
    }

    deinit {
        tearDownNotificationCenterObservers()
    }

    private func openTourWithFinishingCompletion(tourFinishedCompletion: () -> ()) {
        // TODO: should open child coordinator using `openChild`
        // TODO: completion stuff, should be handled in here, should not come via param
        let tourVM = TourLoginViewModel()
        let tourVC = TourLoginViewController(viewModel: tourVM, completion: tourFinishedCompletion)
        tabBarCtl.presentViewController(tourVC, animated: false, completion: nil)
    }

    func openTab(tab: Tab) {
        openTab(tab, force: false)
    }
}


// MARK: - AppNavigator

extension AppCoordinator: AppNavigator {
    func open() {
        let openAppWithInitialDeepLink: () -> () = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.appNavigatorDidOpenApp()

            if let deepLink = strongSelf.deepLinksRouter.consumeInitialDeepLink() {
                strongSelf.openDeepLink(deepLink, initialDeepLink: true)
                // Tracking
                let event = TrackerEvent.openApp(deepLink.campaign, medium: deepLink.medium, source: deepLink.source)
                TrackerProxy.sharedInstance.trackEvent(event)
            } else {
                // Tracking
                let event = TrackerEvent.openApp(source: .Direct)
                TrackerProxy.sharedInstance.trackEvent(event)
            }
        }

        if !keyValueStorage[.didShowOnboarding] {
            keyValueStorage[.didShowOnboarding] = true

            // If I have to show the onboarding, then I assume it is the first time the user opens the app:
            if keyValueStorage[.firstRunDate] == nil {
                keyValueStorage[.firstRunDate] = NSDate()
            }

            pushPermissionsManager.shouldAskForListPermissionsOnCurrentSession = false

            openTourWithFinishingCompletion(openAppWithInitialDeepLink)
        } else {
            openAppWithInitialDeepLink()
        }
    }

    func openForceUpdateAlertIfNeeded() {
        guard configManager.shouldForceUpdate else { return }

        let application = UIApplication.sharedApplication()

        guard let url = NSURL(string: Constants.appStoreURL) else { return }
        guard application.canOpenURL(url) else { return }

        let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle,
                                      message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .Alert)
        let openAppStore = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .Default) { _ in
            application.openURL(url)
        }
        alert.addAction(openAppStore)
        tabBarCtl.presentViewController(alert, animated: true, completion: nil)
    }

    func openSell(source: PostingSource) {
        let sellCoordinator = SellCoordinator(source: source)
        sellCoordinator.delegate = self
        openCoordinator(coordinator: sellCoordinator, parent: tabBarCtl, animated: true, completion: nil)
    }

    func openUserRating(source: RateUserSource, data: RateUserData) {
        let userRatingCoordinator = UserRatingCoordinator(source: source, data: data)
        userRatingCoordinator.delegate = self
        openCoordinator(coordinator: userRatingCoordinator, parent: tabBarCtl, animated: true, completion: nil)
    }
}


// MARK: - PromoteProductViewControllerDelegate

extension AppCoordinator: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {
        promoteProductPostActions(promotionSource)
    }

    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource) {
        if promotionSource == .ProductSell {
            keyValueStorage.shouldShowCommercializerAfterPosting = false
        }
        promoteProductPostActions(promotionSource)
    }
}

private extension AppCoordinator {
    func promoteProductPostActions(source: PromotionSource) {
        if source.hasPostPromotionActions {
            if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.Sell) {
                pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .Sell, completion: nil)
            } else if ratingManager.shouldShowRating {
                showAppRatingViewIfNeeded(.ProductSellComplete)
            }
        }
    }

    func showAppRatingViewIfNeeded(source: EventParameterRatingSource) -> Bool {
        return tabBarCtl.showAppRatingViewIfNeeded(source)
    }
}


// MARK: - CoordinatorDelegate

extension AppCoordinator: CoordinatorDelegate {
    func coordinatorDidClose(coordinator: Coordinator) {
        child = nil
    }
}

// MARK: - SellCoordinatorDelegate

extension AppCoordinator: SellCoordinatorDelegate {
    func sellCoordinatorDidCancel(coordinator: SellCoordinator) {}

    func sellCoordinator(coordinator: SellCoordinator, didFinishWithProduct product: Product) {
        refreshSelectedProductsRefreshable()

        guard !openPromoteIfNeeded(product: product) else { return }
        openAfterSellDialogIfNeeded()
    }
}


// MARK: - UserRatingCoordinatorDelegate

extension AppCoordinator: UserRatingCoordinatorDelegate {
    func userRatingCoordinatorDidCancel(coordinator: UserRatingCoordinator) {}

    func userRatingCoordinatorDidFinish(coordinator: UserRatingCoordinator, withRating rating: Int?) {
        if rating == 5 {
            tabBarCtl.showAppRatingView(EventParameterRatingSource.Chat)
        }
    }
}

private extension AppCoordinator {
    func refreshSelectedProductsRefreshable() {
        guard let selectedVC = tabBarCtl.selectedViewController else { return }
        guard let refreshable = topViewControllerInController(selectedVC) as? ProductsRefreshable else { return }
        refreshable.productsRefresh()
    }

    func openPromoteIfNeeded(product product: Product) -> Bool {
        // TODO: Promote Coordinator (move tracking into promote coordinator)

        // We do not promote if it's a failure or if it's a success w/o country code
        guard let productId = product.objectId, countryCode = product.postalAddress.countryCode else { return false }
        guard keyValueStorage.shouldShowCommercializerAfterPosting else { return false }
        // We do not promote if we do not have promo themes for the given country code
        let themes = commercializerRepository.templatesForCountryCode(countryCode)
        guard let promoteVM = PromoteProductViewModel(productId: productId, themes: themes, commercializers: [],
                                                      promotionSource: .ProductSell) else { return false }
        let promoteVC = PromoteProductViewController(viewModel: promoteVM)
        promoteVC.delegate = self
        tabBarCtl.presentViewController(promoteVC, animated: true, completion: nil)

        // Tracking
        let event = TrackerEvent.commercializerStart(productId, typePage: .Sell)
        TrackerProxy.sharedInstance.trackEvent(event)

        return true
    }

    func openAfterSellDialogIfNeeded() -> Bool {
        if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.Sell) {
            pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .Sell,
                                                                             completion: nil)
        } else if ratingManager.shouldShowRating {
            showAppRatingViewIfNeeded(.ProductSellComplete)
        } else {
            return false
        }
        return true
    }
}


// MARK: - UITabBarControllerDelegate

extension AppCoordinator: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool {

        let topVC = topViewControllerInController(viewController)
        let selectedViewController = tabBarController.selectedViewController

        if let scrollableToTop = topVC as? ScrollableToTop where selectedViewController == viewController {
            scrollableToTop.scrollToTop()
        }

        guard let tab = tabAtController(viewController) else { return false }

        let shouldOpenLogin = tab.logInRequired && !sessionManager.loggedIn
        if let source = tab.logInSource where shouldOpenLogin {
            openLogin(.FullScreen, source: source, afterLogInSuccessful: { [weak self] in
                self?.openTab(tab, force: true)
            })
        }
        return !shouldOpenLogin
    }
}


// MARK: - Private methods
// MARK: > Setup / tear down

private extension AppCoordinator {
    private func setupDeepLinkingRx() {
        deepLinksRouter.deepLinks.asObservable()
            .filter { deepLink in
                //We only want links that open from outside the app
                switch deepLink.origin {
                case .Link, .ShortCut:
                    return true
                case .Push(let appActive):
                    return !appActive
                }
            }.subscribeNext { [weak self] deepLink in
                self?.openDeepLink(deepLink)
            }.addDisposableTo(disposeBag)
    }

    private func setupNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout(_:)),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(kickedOut(_:)),
                                                         name: SessionManager.Notification.KickedOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(askUserToUpdateLocation),
                                                         name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)
    }

    private func tearDownNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


// MARK: > NSNotificationCenter

private extension AppCoordinator {
    dynamic private func logout(notification: NSNotification) {
        openTab(.Home)
    }

    dynamic private func kickedOut(notification: NSNotification) {
        tabBarCtl.showAutoFadingOutMessageAlert(LGLocalizedString.toastErrorInternal)
    }

    dynamic private func askUserToUpdateLocation() {
        guard let navCtl = selectedNavigationController() else { return }

        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .StyledText(LGLocalizedString.commonOk, .Default)) {
            Core.locationManager.setAutomaticLocation(nil)
        }
        navCtl.showAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: LGLocalizedString.commonCancel, actions: [yesAction])

        // We should ask only one time
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue,
                                                            object: nil)
    }
}


// MARK: > Helper

private extension AppCoordinator {
    private func shouldOpenTab(tab: Tab) -> Bool {
        guard let vc = controllerAtTab(tab) else { return false }
        return tabBarController(tabBarCtl, shouldSelectViewController: vc)
    }

    private func controllerAtTab(tab: Tab) -> UIViewController? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        guard 0..<vcs.count ~= tab.index else { return nil }
        return vcs[tab.index]
    }

    private func tabAtController(controller: UIViewController) -> Tab? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        let vc = controller.navigationController ?? controller
        guard let index = vcs.indexOf(vc) else { return nil }
        return Tab(index: index)
    }

    private func topViewControllerInController(controller: UIViewController) -> UIViewController {
        if let navCtl = controller as? UINavigationController {
            return navCtl.topViewController ?? navCtl
        }
        return controller
    }

    private func selectedNavigationController() -> UINavigationController? {
        return tabBarCtl.selectedViewController as? UINavigationController
    }
}


// MARK: > Navigation

private extension AppCoordinator {
    func openCoordinator(coordinator coordinator: Coordinator, parent: UIViewController, animated: Bool,
                                     completion: (() -> Void)?) {
        guard child == nil else { return }
        child = coordinator
        coordinator.open(parent: parent, animated: animated, completion: completion)
    }

    func openTab(tab: Tab, force: Bool) {
        let shouldOpen = force || shouldOpenTab(tab)
        if shouldOpen {
            tabBarCtl.switchToTab(tab)
        }
    }

    func openLogin(style: LoginStyle, source: EventParameterLoginSourceValue, afterLogInSuccessful: () -> ()) {
        let viewModel = SignUpViewModel(source: source)
        switch style {
        case .FullScreen:
            let vc = MainSignUpViewController(viewModel: viewModel)
            vc.afterLoginAction = afterLogInSuccessful
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.view.backgroundColor = UIColor.whiteColor()
            tabBarCtl.presentViewController(navCtl, animated: true, completion: nil)
        case .Popup(let message):
            let vc = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
            vc.preDismissAction = nil
            vc.afterLoginAction = afterLogInSuccessful
            tabBarCtl.presentViewController(vc, animated: true, completion: nil)
        }
    }

    func openDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {
        var afterDelayClosure: (() -> Void)?
        switch deepLink.action {
        case .Home:
            openTab(.Home, force: false)
        case .Sell:
            openSell(.DeepLink)
        case let .Product(productId):
            afterDelayClosure = { [weak self] in
                self?.openProductWithId(productId)
            }
        case let .User(userId):
            afterDelayClosure = { [weak self] in
                self?.openUserWithId(userId)
            }
        case .Conversations:
            openTab(.Chats, force: false)
        case let .Conversation(data):
            afterDelayClosure = { [weak self] in
                self?.openConversationWithData(data)
            }
        case .Message(_, let data):
            afterDelayClosure = { [weak self] in
                self?.openConversationWithData(data)
            }
        case .Search(let query, let categories):
            openTab(.Home, force: false)
            afterDelayClosure = { [weak self] in
                self?.openSearch(query, categoriesString: categories)
            }
        case .ResetPassword(let token):
            openTab(.Home, force: false)
            afterDelayClosure = { [weak self] in
                self?.openResetPassword(token)
            }
        case .Commercializer:
            break // Handled on CommercializerManager
        case .CommercializerReady(let productId, let templateId):
            if initialDeepLink {
                CommercializerManager.sharedInstance.commercializerReadyInitialDeepLink(productId: productId,
                                                                                        templateId: templateId)
            }
        case .UserRatings:
            openTab(.Profile)
            afterDelayClosure = { [weak self] in
                self?.openMyUserRatings()
            }
        case let .UserRating(ratingId):
            openTab(.Profile)
            afterDelayClosure = { [weak self] in
                self?.openUserRatingForUserFromRating(ratingId)
            }
        }

        if let afterDelayClosure = afterDelayClosure {
            delay(0.5) { _ in
                afterDelayClosure()
            }
        }
    }

    func openProductWithId(productId: String) {
        guard let navCtl = selectedNavigationController() else { return }

        navCtl.showLoadingMessageAlert()
        productRepository.retrieve(productId) { result in
            if let product = result.value {
                navCtl.dismissLoadingMessageAlert {
                    guard let vc = ProductDetailFactory.productDetailFromProduct(product) else { return }
                    navCtl.pushViewController(vc, animated: true)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func openUserWithId(userId: String) {
        guard let navCtl = selectedNavigationController() else { return }

        // If opening my own user, just go to the profile tab
        guard myUserRepository.myUser?.objectId != userId else {
            openTab(.Home)
            return
        }

        navCtl.showLoadingMessageAlert()
        userRepository.show(userId, includeAccounts: false) { result in
            if let user = result.value {
                let viewModel = UserViewModel(user: user, source: .TabBar)
                let vc = UserViewController(viewModel: viewModel)

                navCtl.dismissLoadingMessageAlert { navCtl.pushViewController(vc, animated: true) }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                navCtl.dismissLoadingMessageAlert { navCtl.showAutoFadingOutMessageAlert(message) }
            }
        }
    }

    func openConversationWithData(data: ConversationData) {
        // TODO: After changing the tab, all this should be forwarded to chat coordinator
        if let selectedVC = selectedNavigationController(), chatVC = topViewControllerInController(selectedVC)
            as? ChatViewController where chatVC.isMatchingConversationData(data){
            //If the user is already in the conversation, just do nothing. The conversation will update itself
            return
        }

        openTab(.Chats)
        switch data {
        case let .Conversation(conversationId):
            return openChatWithConversationId(conversationId)
        case let .ProductBuyer(productId, buyerId):
            return openChatWithProductId(productId, buyerId: buyerId)
        }
    }

    func openChatWithProductId(productId: String, buyerId: String) {
        guard let navCtl = selectedNavigationController() else { return }

        navCtl.showLoadingMessageAlert()
        chatRepository.retrieveMessagesWithProductId(productId, buyerId: buyerId, page: 0,
                                                     numResults: Constants.numMessagesPerPage) { [weak self] result in
                                                        self?.openChatWithResult(result)
        }
    }

    func openChatWithConversationId(conversationId: String) {
        guard let navCtl = selectedNavigationController() else { return }

        navCtl.showLoadingMessageAlert()
        chatRepository.retrieveMessagesWithConversationId(conversationId, page: 0,
                                                          numResults: Constants.numMessagesPerPage) { [weak self] result in
                                                            self?.openChatWithResult(result)
        }
    }

    private func openChatWithResult(result: ChatResult) {
        guard let navCtl = selectedNavigationController() else { return }

        var dismissLoadingCompletion: (() -> Void)? = nil
        if let chat = result.value {
            guard let viewModel = OldChatViewModel(chat: chat) else { return }
            let chatVC = OldChatViewController(viewModel: viewModel)
            dismissLoadingCompletion = { navCtl.pushViewController(chatVC, animated: true) }

        } else if let error = result.error {
            let message: String
            switch error {
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                message = LGLocalizedString.commonChatNotAvailable
            }
            dismissLoadingCompletion = { navCtl.showAutoFadingOutMessageAlert(message) }
        }
        navCtl.dismissLoadingMessageAlert(dismissLoadingCompletion)
    }


    private func openSearch(query: String, categoriesString: String?) {
        guard let navCtl = selectedNavigationController() else { return }

        var filters = ProductFilters()
        if let categoriesString = categoriesString {
            filters.selectedCategories = ProductCategory.categoriesFromString(categoriesString)
        }
        let viewModel = MainProductsViewModel(searchString: query, filters: filters)
        let vc = MainProductsViewController(viewModel: viewModel)

        navCtl.pushViewController(vc, animated: true)
    }

    private func openResetPassword(token: String) {
        let viewModel = ChangePasswordViewModel(token: token)
        let vc = ChangePasswordViewController(viewModel: viewModel)
        let navCtl = UINavigationController(rootViewController: vc)

        // TODO: Should open a Reset Password coordinator child calling `openChild`
        tabBarCtl.presentViewController(navCtl, animated: true, completion: nil)
    }

    private func openMyUserRatings() {
        guard FeatureFlags.userRatings else { return }
        guard let navCtl = selectedNavigationController() else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        let viewModel = UserRatingListViewModel(userId: myUserId)

        let viewController = UserRatingListViewController(viewModel: viewModel)
        navCtl.pushViewController(viewController, animated: true)
    }

    private func openUserRatingForUserFromRating(ratingId: String) {
        guard FeatureFlags.userRatings else { return }
        guard let navCtl = selectedNavigationController() else { return }

        navCtl.showLoadingMessageAlert()
        userRatingRepository.show(ratingId) { [weak self] result in
            if let rating = result.value, data = RateUserData(user: rating.userFrom) {
                navCtl.dismissLoadingMessageAlert {
                    self?.openUserRating(.DeepLink, data: data)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonUserReviewNotAvailable
                }
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }
}


// MARK: Tab helper

private extension Tab {
    var logInRequired: Bool {
        switch self {
        case .Home, .Categories, Sell:
            return false
        case .Notifications, .Chats, .Profile:
            return true
        }
    }
    var logInSource: EventParameterLoginSourceValue? {
        switch self {
        case .Home, .Categories:
            return nil
        case .Notifications:
            return .Notifications
        case .Sell:
            return .Sell
        case .Chats:
            return .Chats
        case .Profile:
            return .Profile
        }
    }
}
