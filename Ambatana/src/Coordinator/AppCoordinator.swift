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

//protocol AppCoordinatorType: Coordinator, UITabBarControllerDelegate {
//    var window: UIWindow { get }
//    var tabBarCtl: TabBarController { get }
//
//    //    var homeCoordinator: CoordinatorType { get }
//    //    var categoriesCoordinator: CoordinatorType { get }
//    //    var chatCoordinator: CoordinatorType { get }
//    //    var profileCoordinator: CoordinatorType { get }
//
//    func open()
//    func openForceUpdateAlertIfNeeded()
//    func openSell()
//}

enum AppCoordinatorRequestCode: Int {
    case AppOpen
}


final class AppCoordinator: NSObject, Coordinator {
    var children: [Coordinator]
    var viewController: UIViewController { return tabBarCtl }

    private let tabBarCtl: TabBarController

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let userDefaultsManager: UserDefaultsManager
    private let pushPermissionsManager: PushPermissionsManager

    private let deepLinksRouter: DeepLinksRouter

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let chatRepository: OldChatRepository

    weak var delegate: AppNavigatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(tabBarController: TabBarController, configManager: ConfigManager) {
        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let pushPermissionsManager = PushPermissionsManager.sharedInstance

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.oldChatRepository

        self.init(tabBarController: tabBarController, configManager: configManager,
                  sessionManager: Core.sessionManager, userDefaultsManager: UserDefaultsManager.sharedInstance,
                  pushPermissionsManager: pushPermissionsManager, deepLinksRouter: deepLinksRouter,
                  productRepository: productRepository, userRepository: userRepository,
                  myUserRepository: myUserRepository, chatRepository: chatRepository)
    }

    init(tabBarController: TabBarController, configManager: ConfigManager,
         sessionManager: SessionManager, userDefaultsManager: UserDefaultsManager,
         pushPermissionsManager: PushPermissionsManager, deepLinksRouter: DeepLinksRouter,
         productRepository: ProductRepository, userRepository: UserRepository, myUserRepository: MyUserRepository,
         chatRepository: OldChatRepository) {

        self.children = []

        self.tabBarCtl = tabBarController

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.userDefaultsManager = userDefaultsManager
        self.pushPermissionsManager = pushPermissionsManager

        self.deepLinksRouter = deepLinksRouter

        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository

        super.init()
        tabBarCtl.delegate = self

        setupDeepLinkingRx()
        setupNotificationCenterObservers()
    }

    deinit {
        tearDownNotificationCenterObservers()
    }

    // TODO: 🌶 Refactor the completion stuff, should be handled in here
    private func openTourWithFinishingCompletion(tourFinishedCompletion: () -> ()) {
        // TODO: 🌶 open a child tour coordinator
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
        let openInitialDeepLink: () -> () = { [weak self] in
            guard let deepLink = self?.deepLinksRouter.consumeInitialDeepLink() else { return }
            self?.openDeepLink(deepLink, initialDeepLink: true)
        }

        if !userDefaultsManager.loadDidShowOnboarding() {
            userDefaultsManager.saveDidShowOnboarding()

            pushPermissionsManager.shouldAskForListPermissionsOnCurrentSession = false

            openTourWithFinishingCompletion(openInitialDeepLink)
        } else {
            openApp()
            openInitialDeepLink()
        }
    }

    private func openApp() {
        delegate?.appNavigatorDidOpenApp()
    }

    func openForceUpdateAlertIfNeeded() {
        guard configManager.shouldForceUpdate else { return }

        let itunesURL = String(format: Constants.appStoreURL, arguments: [EnvironmentProxy.sharedInstance.appleAppId])
        let application = UIApplication.sharedApplication()

        guard let url = NSURL(string: itunesURL) else { return }
        guard application.canOpenURL(url) else { return }

        let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle,
                                      message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .Alert)
        let openAppStore = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .Default) { _ in
            application.openURL(url)
        }
        alert.addAction(openAppStore)
        viewController.presentViewController(alert, animated: true, completion: nil)
    }

    func openSellIfLoggedIn() {
        if sessionManager.loggedIn {
            openSell()
        } else {
            openLogin(.FullScreen, source: .Sell, afterLogInSuccessful: { [weak self] in
                self?.openSell()
            })
        }
    }
}


// MARK: - PromoteProductViewControllerDelegate

extension AppCoordinator: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {
        promoteProductPostActions(promotionSource)
    }

    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource) {
        promoteProductPostActions(promotionSource)
    }

    private func promoteProductPostActions(source: PromotionSource) {
        if source.hasPostPromotionActions {
            if PushPermissionsManager.sharedInstance
                .shouldShowPushPermissionsAlertFromViewController(.Sell) {
                PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(tabBarCtl, type: .Sell, completion: nil)
            } else if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
                showAppRatingViewIfNeeded()
            }
        }
    }
}


// MARK: - SellProductViewControllerDelegate

extension AppCoordinator: SellProductViewControllerDelegate {
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool,
                                   withPromoteProductViewModel promoteProductVM: PromoteProductViewModel?) {
        guard successfully else { return }

        refreshSelectedProductsRefreshable()
        if let promoteProductVM = promoteProductVM {
            let promoteProductVC = PromoteProductViewController(viewModel: promoteProductVM)
            promoteProductVC.delegate = self
            let event = TrackerEvent.commercializerStart(promoteProductVM.productId, typePage: .Sell)
            TrackerProxy.sharedInstance.trackEvent(event)
            tabBarCtl.presentViewController(promoteProductVC, animated: true, completion: nil)
        } else if PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.Sell) {
            PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(tabBarCtl, type: .Sell, completion: nil)
        } else if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
            showAppRatingViewIfNeeded()
        }
    }

    private func refreshSelectedProductsRefreshable() {
        if let selectedVC = tabBarCtl.selectedViewController,
            refreshable = topViewControllerInController(selectedVC) as? ProductsRefreshable {
            refreshable.productsRefresh()
        }
    }

    /**
     Shows the app rating if needed.

     - returns: Whether app rating has been shown or not
     */
    private func showAppRatingViewIfNeeded() -> Bool {
        guard let navCtl = selectedNavigationController(), ratingView = AppRatingView.ratingView()
            where !userDefaultsManager.loadAlreadyRated() else { return false }

        UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
        ratingView.setupWithFrame(navCtl.view.frame, contactBlock: { (vc) -> Void in
            navCtl.pushViewController(vc, animated: true)
        })
        tabBarCtl.view.addSubview(ratingView)
        return true
    }

    func sellProductViewController(sellVC: SellProductViewController?, didFinishPostingProduct
        postedViewModel: ProductPostedViewModel) {

        let productPostedVC = ProductPostedViewController(viewModel: postedViewModel)
        productPostedVC.delegate = self
        tabBarCtl.presentViewController(productPostedVC, animated: true, completion: nil)
    }

    func sellProductViewController(sellVC: SellProductViewController?,
                                   didEditProduct editVC: EditSellProductViewController?) {
        guard let editVC = editVC else { return }
        let navC = UINavigationController(rootViewController: editVC)
        tabBarCtl.presentViewController(navC, animated: true, completion: nil)
    }

    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?) {
        openSell()
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

        if let navVC = viewController as? UINavigationController, topVC = navVC.topViewController as? ScrollableToTop
            where selectedViewController == viewController {
            topVC.scrollToTop()
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
            .filter { _ in
                // We only want links that open from outside the app
                UIApplication.sharedApplication().applicationState != .Active
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
                           cancelLabel: LGLocalizedString.commonCancel,
                           actions: [yesAction])

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
    func openSell() {
        // TODO: should open child coordinator `openChild`
        SellProductControllerFactory.presentSellProductOn(viewController: tabBarCtl, delegate: self)
    }

    func openTab(tab: Tab, force: Bool) {
        let shouldOpen = force || (!force && shouldOpenTab(tab))
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
// TODO: 🌶
//            vc.preDismissAction = preDismissAction
            vc.afterLoginAction = afterLogInSuccessful
            tabBarCtl.presentViewController(vc, animated: true, completion: nil)
        }
    }

    func openDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {
        var afterDelayClosure: (() -> Void)?
        switch deepLink {
        case .Home:
            openTab(.Home, force: false)
        case .Sell:
            openSell()
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
        }

        if let afterDelayClosure = afterDelayClosure {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { _ in
                afterDelayClosure()
            })
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
                case .Internal, .NotFound, .Unauthorized, .Forbidden:
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
                case .Internal, .NotFound, .Unauthorized, .Forbidden:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                navCtl.dismissLoadingMessageAlert { navCtl.showAutoFadingOutMessageAlert(message) }
            }
        }
    }

    func openConversationWithData(data: ConversationData) {
        guard let selectedVC = selectedNavigationController() else { return }
        guard let chatVC = topViewControllerInController(selectedVC) as? ChatViewController else { return }
        guard !chatVC.isMatchingConversationData(data) else { return }

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
            guard let viewModel = ChatViewModel(chat: chat) else { return }
            let vc = ChatViewController(viewModel: viewModel)
            dismissLoadingCompletion = { navCtl.pushViewController(vc, animated: true) }

        } else if let error = result.error {
            let message: String
            switch error {
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal, .NotFound, .Unauthorized, .Forbidden:
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
}


// MARK: Tab helper

private extension Tab {
    var logInRequired: Bool {
        switch self {
        case .Home, .Categories:
            return false
        case .Notifications, .Sell, .Chats, .Profile:
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