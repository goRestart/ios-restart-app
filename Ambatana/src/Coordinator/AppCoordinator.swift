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

protocol AppCoordinatorDelegate: class {
    func appCoordinatorDidOpenApp(coordinator: AppCoordinator)
    func appCoordinatorDidOpenTour(coordinator: AppCoordinator)
    func appCoordinator(coordinator: AppCoordinator, didOpenDeepLink: DeepLink)
}

class AppCoordinator: NSObject, AppCoordinatorType {
    let window: UIWindow
    let tabBarCtl: TabBarController
    var children: [CoordinatorType]

//    var homeCoordinator: CoordinatorType
//    var categoriesCoordinator: CoordinatorType
//    var chatCoordinator: CoordinatorType
//    var profileCoordinator: CoordinatorType

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let userDefaultsManager: UserDefaultsManager
    private let pushPermissionsManager: PushPermissionsManager
    private let deepLinksRouter: DeepLinksRouter

    let disposeBag = DisposeBag()

    weak var delegate: AppCoordinatorDelegate?


    convenience init(window: UIWindow, configManager: ConfigManager) {
        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let pushPermissionsManager = PushPermissionsManager.sharedInstance

        self.init(window: window, configManager: configManager, sessionManager: Core.sessionManager,
                  userDefaultsManager: UserDefaultsManager.sharedInstance,
                  pushPermissionsManager: pushPermissionsManager, deepLinksRouter: deepLinksRouter)
    }

    init(window: UIWindow, configManager: ConfigManager, sessionManager: SessionManager,
         userDefaultsManager: UserDefaultsManager, pushPermissionsManager: PushPermissionsManager,
         deepLinksRouter: DeepLinksRouter) {
        self.window = window
        let tabBarViewModel = TabBarViewModel()
        self.tabBarCtl = TabBarController(viewModel: tabBarViewModel)
        self.children = []

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.userDefaultsManager = userDefaultsManager
        self.pushPermissionsManager = pushPermissionsManager
        self.deepLinksRouter = deepLinksRouter

        super.init()
        tabBarViewModel.coordinator = self
        tabBarCtl.delegate = self
        window.rootViewController = tabBarCtl
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


// MARK: - AppCoordinatorType methods

extension AppCoordinator {
    func open() {

        //sensorLocationUpdatesEnabled > did open app / did open tour

        window.makeKeyAndVisible()

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
        delegate?.appCoordinatorDidOpenApp(self)
    }

    func openForceUpdateDialogIfNeeded() {
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
        window.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

    func openSell() {
        // TODO: 🌶 If already showing do not push
        if sessionManager.loggedIn {
            SellProductControllerFactory.presentSellProductOn(viewController: tabBarCtl, delegate: self)
        } else {
            openLogin(.FullScreen, source: .Sell, afterLogInSuccessful: { [weak self] in
                guard let strongSelf = self else { return }
                let vc = strongSelf.tabBarCtl
                SellProductControllerFactory.presentSellProductOn(viewController: vc, delegate: self)
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
        guard !userDefaultsManager.loadAlreadyRated(), let navCtl = tabBarCtl.selectedViewController
            as? UINavigationController, let ratingView = AppRatingView.ratingView() else { return false}

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
// MARK: > Helper

private extension AppCoordinator {
    private func shouldOpenTab(tab: Tab) -> Bool {
        guard let vc = controllerAtTab(tab) else { return false }
        return tabBarController(tabBarCtl, shouldSelectViewController: vc)
    }

    private func controllerAtTab(tab: Tab) -> UIViewController? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        guard 0..<vcs.count ~= tab.rawValue else { return nil }
        return vcs[tab.rawValue]
    }

    private func tabAtController(controller: UIViewController) -> Tab? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        let vc = controller.navigationController ?? controller
        guard let index = vcs.indexOf(vc) else { return nil }

        let rawValue: Int = vcs.startIndex.distanceTo(index)
        return Tab(rawValue: rawValue)
    }

    private func topViewControllerInController(controller: UIViewController) -> UIViewController {
        if let navCtl = controller as? UINavigationController {
            return navCtl.topViewController ?? navCtl
        }
        return controller
    }
}


// MARK: > Navigation

private extension AppCoordinator {
    private func openTab(tab: Tab, force: Bool) {
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
// TODO: 🌶
            tabBarCtl.presentViewController(navCtl, animated: true, completion: nil)
        case .Popup(let message):
            let vc = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
// TODO: 🌶
//            vc.preDismissAction = preDismissAction
            vc.afterLoginAction = afterLogInSuccessful
            tabBarCtl.presentViewController(vc, animated: true, completion: nil)
        }
    }

    private func openDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {
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
            //            openTab(.Chats, force: false)
            afterDelayClosure = { [weak self] in
                self?.openConversationWithData(data)
            }
        case .Message(_, let data):
            //            openTab(.Chats, force: false)
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
            dispatch_after(delayTime, dispatch_get_main_queue(), { [weak self] in
                afterDelayClosure()

                guard let strongSelf = self else { return }
                strongSelf.delegate?.appCoordinator(strongSelf, didOpenDeepLink: deepLink)
            })
        }
    }

    private func openProductWithId(productId: String) {
        // TODO: 🌶 If already showing do not push
    }

    private func openUserWithId(userId: String) {
        // TODO: 🌶 If already showing do not push
    }

    private func openConversationWithData(data: ConversationData) {
        // TODO: 🌶 If already showing do not push
    }

    private func openSearch(query: String, categoriesString: String?) {

    }

    private func openResetPassword(token: String) {
        
    }
}

private extension Tab {
    var logInRequired: Bool {
        switch self {
        case .Home, .Categories:
            return false
        case .Sell, .Chats, .Profile:
            return true
        }
    }
    var logInSource: EventParameterLoginSourceValue? {
        switch self {
        case .Home, .Categories:
            return nil
        case .Sell:
            return .Sell
        case .Chats:
            return .Chats
        case .Profile:
            return .Profile
        }
    }
}