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

    let tabBarCtl: TabBarController

    private let mainTabBarCoordinator: MainTabCoordinator
    private let secondTabBarCoordinator: TabCoordinator
    private let chatsTabBarCoordinator: ChatsTabCoordinator
    private let profileTabBarCoordinator: ProfileTabCoordinator
    private let tabCoordinators: [TabCoordinator]

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let keyValueStorage: KeyValueStorage
    private let pushPermissionsManager: PushPermissionsManager
    private let ratingManager: RatingManager
    private let bubbleNotifManager: BubbleNotificationManager

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

    convenience init(configManager: ConfigManager) {
        let tabBarViewModel = TabBarViewModel()
        let tabBarController = TabBarController(viewModel: tabBarViewModel)

        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let pushPermissionsManager = PushPermissionsManager.sharedInstance
        let ratingManager = RatingManager.sharedInstance
        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let bubbleManager = BubbleNotificationManager.sharedInstance

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.oldChatRepository
        let commercializerRepository = Core.commercializerRepository
        let userRatingRepository = Core.userRatingRepository

        self.init(tabBarController: tabBarController, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                  pushPermissionsManager: pushPermissionsManager, ratingManager: ratingManager,
                  deepLinksRouter: deepLinksRouter, bubbleManager: bubbleManager, productRepository: productRepository,
                  userRepository: userRepository, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  commercializerRepository: commercializerRepository, userRatingRepository: userRatingRepository)
        tabBarViewModel.navigator = self
    }

    init(tabBarController: TabBarController, configManager: ConfigManager,
         sessionManager: SessionManager, keyValueStorage: KeyValueStorage,
         pushPermissionsManager: PushPermissionsManager, ratingManager: RatingManager, deepLinksRouter: DeepLinksRouter,
         bubbleManager: BubbleNotificationManager, productRepository: ProductRepository, userRepository: UserRepository,
         myUserRepository: MyUserRepository, chatRepository: OldChatRepository,
         commercializerRepository: CommercializerRepository, userRatingRepository: UserRatingRepository) {

        self.tabBarCtl = tabBarController
        
        self.mainTabBarCoordinator = MainTabCoordinator()
        self.secondTabBarCoordinator = FeatureFlags.notificationsSection ? NotificationsTabCoordinator() :
                                                                           CategoriesTabCoordinator()
        self.chatsTabBarCoordinator = ChatsTabCoordinator()
        self.profileTabBarCoordinator = ProfileTabCoordinator()
        self.tabCoordinators = [mainTabBarCoordinator, secondTabBarCoordinator, chatsTabBarCoordinator,
                                profileTabBarCoordinator]

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager
        self.bubbleNotifManager = bubbleManager

        self.deepLinksRouter = deepLinksRouter

        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.commercializerRepository = commercializerRepository
        self.userRatingRepository = userRatingRepository

        super.init()
        setupTabBarController()
        setupTabCoordinators()
        setupDeepLinkingRx()
        setupNotificationCenterObservers()
    }

    deinit {
        tearDownNotificationCenterObservers()
    }

    func openTab(tab: Tab) {
        openTab(tab, force: false)
    }
}


// MARK: - AppNavigator

extension AppCoordinator: AppNavigator {
    func open() {
        guard !openOnboarding() else { return }
        delegate?.appNavigatorDidOpenApp()

        if let deepLink = deepLinksRouter.consumeInitialDeepLink() {
            openExternalDeepLink(deepLink, initialDeepLink: true)
        }

        //TODO: REMOVE, JUST TO TEST
        let action = UIAction(interface: .Text("action mu larga mu laaarga"), action: {})
        bubbleNotifManager.showBubble("Test buble molongui que teoricamente ocupa dos lineas", action: action, duration: 0)
    }

    private func openOnboarding() -> Bool {
        guard !keyValueStorage[.didShowOnboarding] else { return false }
        keyValueStorage[.didShowOnboarding] = true
        // If I have to show the onboarding, then I assume it is the first time the user opens the app:
        if keyValueStorage[.firstRunDate] == nil {
            keyValueStorage[.firstRunDate] = NSDate()
        }
        pushPermissionsManager.shouldAskForListPermissionsOnCurrentSession = false

        let onboardingCoordinator = OnboardingCoordinator()
        onboardingCoordinator.delegate = self
        openCoordinator(coordinator: onboardingCoordinator, parent: tabBarCtl, animated: true, completion: nil)
        return true
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

    func openVerifyAccounts(types: [VerificationType], source: VerifyAccountsSource) {
        let viewModel = VerifyAccountsViewModel(verificationTypes: types, source: source)
        let viewController = VerifyAccountsViewController(viewModel: viewModel)
        tabBarCtl.presentViewController(viewController, animated: true, completion: nil)
    }
    
    func openNPSSurvey() {
        guard FeatureFlags.showNPSSurvey else { return }
        delay(3) { [weak self] in
            let vc = NPSViewController(viewModel: NPSViewModel())
            self?.tabBarCtl.presentViewController(vc, animated: true, completion: nil)
        }
    }

    func openAppInvite() {
        AppShareViewController.showOnViewControllerIfNeeded(tabBarCtl)
    }

    func canOpenAppInvite() -> Bool {
        return AppShareViewController.canBeShown()
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


// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingCoordinator(coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?) {
        delegate?.appNavigatorDidOpenApp()
        if let source = source where posting {
            openSell(source)
        }
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



// MARK: - TabCoordinatorDelegate

extension AppCoordinator: TabCoordinatorDelegate {
    func tabCoordinator(tabCoordinator: TabCoordinator, setSellButtonHidden hidden: Bool, animated: Bool) {
        tabBarCtl.setSellFloatingButtonHidden(hidden, animated: animated)
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
        let result: Bool
        let afterLogInSuccessful: () -> ()

        switch tab {
        case .Home, .Categories, .Notifications, .Chats, .Profile:
            afterLogInSuccessful = { [weak self] in self?.openTab(tab, force: true) }
            result = !shouldOpenLogin
        case .Sell:
            afterLogInSuccessful = { [weak self] in
                self?.openSell(.SellButton)
            }
            result = false
            if sessionManager.loggedIn {
                openSell(.SellButton)
            }
        }

        if let source = tab.logInSource where shouldOpenLogin {
            openLogin(.FullScreen, source: source, afterLogInSuccessful: afterLogInSuccessful)
        } else {
            switch tab {
            case .Home, .Categories, .Notifications, .Chats, .Profile:
                // tab is changed after returning from this method
                break
            case .Sell:
                openSell(.SellButton)
            }
        }
        return result
    }
}


// MARK: - Private methods
// MARK: > Setup / tear down

private extension AppCoordinator {
    func setupTabBarController() {
        tabBarCtl.delegate = self
        var viewControllers = tabCoordinators.map { $0.navigationController as UIViewController }
        viewControllers.insert(UIViewController(), atIndex: 2)  // Sell
        tabBarCtl.viewControllers = viewControllers
        tabBarCtl.setupTabBarItems()
    }

    func setupTabCoordinators() {
        mainTabBarCoordinator.tabCoordinatorDelegate = self
        secondTabBarCoordinator.tabCoordinatorDelegate = self
        chatsTabBarCoordinator.tabCoordinatorDelegate = self
        profileTabBarCoordinator.tabCoordinatorDelegate = self
        
        mainTabBarCoordinator.appNavigator = self
        secondTabBarCoordinator.appNavigator = self
        chatsTabBarCoordinator.appNavigator = self
        profileTabBarCoordinator.appNavigator = self
    }

    func setupDeepLinkingRx() {
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
                self?.openExternalDeepLink(deepLink)
            }.addDisposableTo(disposeBag)
    }

    func setupNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout(_:)),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(kickedOut(_:)),
                                                         name: SessionManager.Notification.KickedOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(askUserToUpdateLocation),
                                                         name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)
    }

    func tearDownNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


// MARK: > NSNotificationCenter

private extension AppCoordinator {
    dynamic func logout(notification: NSNotification) {
        openTab(.Home)
    }

    dynamic func kickedOut(notification: NSNotification) {
        tabBarCtl.showAutoFadingOutMessageAlert(LGLocalizedString.toastErrorInternal)
    }

    dynamic func askUserToUpdateLocation() {
        guard let navCtl = selectedNavigationController else { return }

        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .StyledText(LGLocalizedString.commonOk, .Default), action: {
            Core.locationManager.setAutomaticLocation(nil)
        })
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
    func shouldOpenTab(tab: Tab) -> Bool {
        guard let vc = controllerAtTab(tab) else { return false }
        return tabBarController(tabBarCtl, shouldSelectViewController: vc)
    }

    func controllerAtTab(tab: Tab) -> UIViewController? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        guard 0..<vcs.count ~= tab.index else { return nil }
        return vcs[tab.index]
    }

    func tabAtController(controller: UIViewController) -> Tab? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        let vc = controller.navigationController ?? controller
        guard let index = vcs.indexOf(vc) else { return nil }
        return Tab(index: index)
    }

    func topViewControllerInController(controller: UIViewController) -> UIViewController {
        if let navCtl = controller as? UINavigationController {
            return navCtl.topViewController ?? navCtl
        }
        return controller
    }

    var selectedNavigationController: UINavigationController? {
        guard let selectedTabCoordinator = selectedTabCoordinator else { return nil }
        return selectedTabCoordinator.navigationController
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
        let viewModel = SignUpViewModel(appearance: .Light, source: source)
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

    func openExternalDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {
        let event = TrackerEvent.openAppExternal(deepLink.campaign, medium: deepLink.medium, source: deepLink.source)
        TrackerProxy.sharedInstance.trackEvent(event)

        openDeepLink(deepLink, initialDeepLink: initialDeepLink)
    }

    func openDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {

        var afterDelayClosure: (() -> Void)?
        switch deepLink.action {
        case .Home:
            afterDelayClosure = { [weak self] in
                self?.openTab(.Home, force: false)
            }
        case .Sell:
            afterDelayClosure = { [weak self] in
                self?.openSell(.DeepLink)
            }
        case let .Product(productId):
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openProduct(ProductDetailData.Id(productId: productId), source: .OpenApp)
            }
        case let .User(userId):
            if userId == myUserRepository.myUser?.objectId {
                openTab(.Profile, force: false)
            } else {
                afterDelayClosure = { [weak self] in
                    self?.selectedTabCoordinator?.openUser(UserDetailData.Id(userId: userId, source: .Link))
                }
            }
        case .Conversations:
            openTab(.Chats, force: false)
        case let .Conversation(data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Chats, force: false)
                self?.chatsTabBarCoordinator.openChat(conversationData: data)
            }
        case .Message(_, let data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Chats, force: false)
                self?.chatsTabBarCoordinator.openChat(conversationData: data)
            }
        case .Search(let query, let categories):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Home, force: false)
                self?.mainTabBarCoordinator.openSearch(query, categoriesString: categories)
            }
        case .ResetPassword(let token):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Home, force: false)
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
            afterDelayClosure = { [weak self] in
                self?.openTab(.Profile)
                self?.openMyUserRatings()
            }
        case let .UserRating(ratingId):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Profile)
                self?.openUserRatingForUserFromRating(ratingId)
            }
        }

        if let afterDelayClosure = afterDelayClosure {
            delay(0.5) { _ in
                afterDelayClosure()
            }
        }
    }

    var selectedTabCoordinator: TabCoordinator? {
        guard let navigationController = tabBarCtl.selectedViewController as? UINavigationController else { return nil }
        for tabCoordinator in tabCoordinators {
            if tabCoordinator.navigationController === navigationController { return tabCoordinator }
        }
        return nil
    }

    func openResetPassword(token: String) {
        let viewModel = ChangePasswordViewModel(token: token)
        let vc = ChangePasswordViewController(viewModel: viewModel)
        let navCtl = UINavigationController(rootViewController: vc)

        // TODO: Should open a Reset Password coordinator child calling `openChild`
        tabBarCtl.presentViewController(navCtl, animated: true, completion: nil)
    }

    func openMyUserRatings() {
        guard FeatureFlags.userRatings else { return }
        guard let navCtl = selectedNavigationController else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        let viewModel = UserRatingListViewModel(userId: myUserId, tabNavigator: profileTabBarCoordinator)

        let viewController = UserRatingListViewController(viewModel: viewModel)
        navCtl.pushViewController(viewController, animated: true)
    }

    func openUserRatingForUserFromRating(ratingId: String) {
        guard FeatureFlags.userRatings else { return }
        guard let navCtl = selectedNavigationController else { return }

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
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError:
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
        case .Home, .Categories, .Sell:
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
