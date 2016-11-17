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
    private let selectedTab: Variable<Tab>
    let chatHeadOverlay: ChatHeadOverlayView

    private let mainTabBarCoordinator: MainTabCoordinator
    private let secondTabBarCoordinator: TabCoordinator
    private let chatsTabBarCoordinator: ChatsTabCoordinator
    private let profileTabBarCoordinator: ProfileTabCoordinator
    private let tabCoordinators: [TabCoordinator]

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let chatHeadManager: ChatHeadManager
    private let keyValueStorage: KeyValueStorage
    private let pushPermissionsManager: PushPermissionsManager
    private let ratingManager: RatingManager
    private let bubbleNotifManager: BubbleNotificationManager
    private let tracker: Tracker

    private let deepLinksRouter: DeepLinksRouter

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let oldChatRepository: OldChatRepository
    private let chatRepository: ChatRepository
    private let commercializerRepository: CommercializerRepository
    private let userRatingRepository: UserRatingRepository

    weak var delegate: AppNavigatorDelegate?

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(configManager: ConfigManager) {
        let tabBarViewModel = TabBarViewModel()
        let tabBarController = TabBarController(viewModel: tabBarViewModel)
        let chatHeadOverlay = ChatHeadOverlayView()

        let sessionManager = Core.sessionManager
        let chatHeadManager = ChatHeadManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let pushPermissionsManager = PushPermissionsManager.sharedInstance
        let ratingManager = RatingManager.sharedInstance
        let deepLinksRouter = DeepLinksRouter.sharedInstance
        let bubbleManager = BubbleNotificationManager.sharedInstance
        let tracker = TrackerProxy.sharedInstance

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let myUserRepository = Core.myUserRepository
        let oldChatRepository = Core.oldChatRepository
        let chatRepository = Core.chatRepository
        let commercializerRepository = Core.commercializerRepository
        let userRatingRepository = Core.userRatingRepository

        self.init(tabBarController: tabBarController, chatHeadOverlay: chatHeadOverlay, configManager: configManager,
                  sessionManager: sessionManager, chatHeadManager: chatHeadManager, keyValueStorage: keyValueStorage,
                  pushPermissionsManager: pushPermissionsManager, ratingManager: ratingManager,
                  deepLinksRouter: deepLinksRouter, bubbleManager: bubbleManager, tracker: tracker,
                  productRepository: productRepository, userRepository: userRepository, myUserRepository: myUserRepository,
                  oldChatRepository: oldChatRepository, chatRepository: chatRepository,
                  commercializerRepository: commercializerRepository, userRatingRepository: userRatingRepository)
        tabBarViewModel.navigator = self
    }

    init(tabBarController: TabBarController, chatHeadOverlay: ChatHeadOverlayView, configManager: ConfigManager,
         sessionManager: SessionManager, chatHeadManager: ChatHeadManager, keyValueStorage: KeyValueStorage,
         pushPermissionsManager: PushPermissionsManager, ratingManager: RatingManager, deepLinksRouter: DeepLinksRouter,
         bubbleManager: BubbleNotificationManager, tracker: Tracker, productRepository: ProductRepository,
         userRepository: UserRepository, myUserRepository: MyUserRepository, oldChatRepository: OldChatRepository,
         chatRepository: ChatRepository, commercializerRepository: CommercializerRepository,
         userRatingRepository: UserRatingRepository) {

        self.tabBarCtl = tabBarController
        self.selectedTab = Variable<Tab>(.Home)
        self.chatHeadOverlay = chatHeadOverlay
        
        self.mainTabBarCoordinator = MainTabCoordinator()
        self.secondTabBarCoordinator = FeatureFlags.notificationsSection ? NotificationsTabCoordinator() :
                                                                           CategoriesTabCoordinator()
        self.chatsTabBarCoordinator = ChatsTabCoordinator()
        self.profileTabBarCoordinator = ProfileTabCoordinator()
        self.tabCoordinators = [mainTabBarCoordinator, secondTabBarCoordinator, chatsTabBarCoordinator,
                                profileTabBarCoordinator]

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.chatHeadManager = chatHeadManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager
        self.bubbleNotifManager = bubbleManager
        self.tracker = tracker

        self.deepLinksRouter = deepLinksRouter

        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.oldChatRepository = oldChatRepository
        self.chatRepository = chatRepository
        self.commercializerRepository = commercializerRepository
        self.userRatingRepository = userRatingRepository

        super.init()
        setupTabBarController()
        setupTabCoordinators()
        setupDeepLinkingRx()
        setupNotificationCenterObservers()
        setupChatHeads()
        setupLeanplumPopUp()
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
        keyValueStorage[.showLiquidCategories] = false
        afterOpenAppEvents()

        if let deepLink = deepLinksRouter.consumeInitialDeepLink() {
            openExternalDeepLink(deepLink, initialDeepLink: true)
        }
    }

    private func openOnboarding() -> Bool {
        guard !keyValueStorage[.didShowOnboarding] else { return false }
        keyValueStorage[.didShowOnboarding] = true
        // If I have to show the onboarding, then I assume it is the first time the user opens the app:
        if keyValueStorage[.firstRunDate] == nil {
            keyValueStorage[.showLiquidCategories] = true
            keyValueStorage[.firstRunDate] = NSDate()
        }
        pushPermissionsManager.shouldAskForListPermissionsOnCurrentSession = false

        let onboardingCoordinator = OnboardingCoordinator()
        onboardingCoordinator.delegate = self
        openCoordinator(coordinator: onboardingCoordinator, parent: tabBarCtl, animated: true, completion: nil)
        return true
    }

    private func afterOpenAppEvents() {
        chatHeadManager.initialize()
        delegate?.appNavigatorDidOpenApp()
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

    func openVerifyAccounts(types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        let viewModel = VerifyAccountsViewModel(verificationTypes: types, source: source, completionBlock: completionBlock)
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
        afterOpenAppEvents()
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
        tracker.trackEvent(TrackerEvent.commercializerStart(productId, typePage: .Sell))

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
                self?.openSell(.TabBar)
            }
            result = false
            if sessionManager.loggedIn {
                openSell(.TabBar)
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
                openSell(.TabBar)
            }
        }
        return result
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        guard let tab = tabAtController(viewController) else { return }
        selectedTab.value = tab
    }
}


// MARK: - ChatHeadGroupViewDelegate

extension AppCoordinator: ChatHeadGroupViewDelegate {
    func chatHeadGroup(view: ChatHeadGroupView, openChatDetailWithId id: String) {
        let data = ConversationData.Conversation(conversationId: id)
        
        openTab(.Chats)
        chatsTabBarCoordinator.openChat(.DataIds(data: data))

        tracker.trackEvent(TrackerEvent.chatHeadsOpen())
    }

    func chatHeadGroupOpenChatList(view: ChatHeadGroupView) {
        openTab(.Chats)

        tracker.trackEvent(TrackerEvent.chatHeadsOpen())
    }
}


// MARK: - ChatHeadOverlayViewDelegate

extension AppCoordinator: ChatHeadOverlayViewDelegate {
    func chatHeadOverlayViewUserDidDismiss(view: ChatHeadOverlayView) {
        tracker.trackEvent(TrackerEvent.chatHeadsDelete())
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
            .subscribeNext { [weak self] deepLink in
                if deepLink.origin.appActive {
                    self?.showInappDeepLink(deepLink)
                } else {
                    self?.openExternalDeepLink(deepLink)
                }
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

    func setupChatHeads() {
        let view: UIView = tabBarCtl.tabBar.superview ?? tabBarCtl.view
        chatHeadOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatHeadOverlay)

        let views: [String: AnyObject] = ["cho": chatHeadOverlay]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cho]-0-|",
                                                                          options: [], metrics: nil, views: views)
        view.addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cho]-0-|",
                                                                          options: [], metrics: nil, views: views)
        view.addConstraints(vConstraints)

        chatHeadOverlay.delegate = self
        chatHeadOverlay.setChatHeadGroupViewDelegate(self)
        chatHeadManager.setChatHeadOverlayView(chatHeadOverlay)

        // Chat heads should be hidden depending on the tab
        let chatHeadsHidden = selectedTab.asObservable()
            .map { $0.chatHeadsHidden }
            .distinctUntilChanged()
        chatHeadsHidden.bindTo(chatHeadOverlay.rx_hidden).addDisposableTo(disposeBag)

        // Chat heads tracker event happens when chat head overlay is not hidden & its chat heads are visible
        let chatHeadsStart = Observable.combineLatest(chatHeadsHidden, chatHeadOverlay.chatHeadsVisible.asObservable()) { !$0 && $1 }
            .distinctUntilChanged()
            .filter { $0 }

        chatHeadsStart.subscribeNext { [weak self] shown in
            self?.tracker.trackEvent(TrackerEvent.chatHeadsStart())
            }.addDisposableTo(disposeBag)
    }

    func tearDownNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension AppCoordinator: CustomLeanplumPresenter {
    
    func setupLeanplumPopUp() {
        Leanplum.customLeanplumAlert(self)
    }
    
    func showLeanplumAlert(title: String?, text: String, image: String, action: UIAction) {
        let alertIcon = UIImage(contentsOfFile: image)
        guard let alert = LGAlertViewController(title: title, text: text, alertType: .IconAlert(icon: alertIcon), actions: [action]) else { return }
        tabBarCtl.presentViewController(alert, animated: true, completion: nil)
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

    /**
     Those links will always come from an inactive state of the app. So it means the user clicked a push, a link or a 
     shortcut. 
     As it was a user action we must perform navigation
     */
    func openExternalDeepLink(deepLink: DeepLink, initialDeepLink: Bool = false) {
        let event = TrackerEvent.openAppExternal(deepLink.campaign, medium: deepLink.medium, source: deepLink.source)
        tracker.trackEvent(event)

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
                self?.chatsTabBarCoordinator.openChat(.DataIds(data: data))
            }
        case .Message(_, let data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.Chats, force: false)
                self?.chatsTabBarCoordinator.openChat(.DataIds(data: data))
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

    /**
     A deeplink has been received while the app is active. It means the user was already inside the app and the deeplink
     was generated.
     We must NOT navigate but show an inapp notification.
     */
    func showInappDeepLink(deepLink: DeepLink) {
        //Avoid showing inapp notification when selling
        if let child = child where child is SellCoordinator { return }

        switch deepLink.action {
        case .Home, .Sell, .Product, .User, .Conversations, .Search, .ResetPassword, .Commercializer,
             .CommercializerReady, .UserRatings, .UserRating:
            return // Do nothing
        case let .Conversation(data):
            showInappChatNotification(data, message: deepLink.origin.message)
        case .Message(_, let data):
            showInappChatNotification(data, message: deepLink.origin.message)
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
        guard FeatureFlags.userReviews else { return }
        guard let navCtl = selectedNavigationController else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        let viewModel = UserRatingListViewModel(userId: myUserId, tabNavigator: profileTabBarCoordinator)

        let viewController = UserRatingListViewController(viewModel: viewModel)
        navCtl.pushViewController(viewController, animated: true)
    }

    func openUserRatingForUserFromRating(ratingId: String) {
        guard FeatureFlags.userReviews else { return }
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

    func showInappChatNotification(data: ConversationData, message: String) {
        guard sessionManager.loggedIn else { return }
        //Avoid showing notification if user is already in that conversation.
        guard let selectedTabCoordinator = selectedTabCoordinator
            where !selectedTabCoordinator.isShowingConversation(data) else { return }

        let conversationId: String
        switch data {
        case let .Conversation(id):
            conversationId = id
        default:
            return
        }

        tracker.trackEvent(TrackerEvent.inappChatNotificationStart())
        if FeatureFlags.websocketChat {
            chatRepository.showConversation(conversationId) { [weak self] result in
                guard let conversation = result.value else { return }
                let action = UIAction(interface: .Text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                    self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                    self?.openTab(.Chats, force: false)
                    self?.selectedTabCoordinator?.openChat(.Conversation(conversation: conversation))
                    })
                let userName = conversation.interlocutor?.name ?? ""
                let justMessage = message.stringByReplacingOccurrencesOfString(userName, withString: "").trim
                let data = BubbleNotificationData(tagGroup: conversationId,
                                                  text: userName,
                                                  infoText: justMessage,
                                                  action: action,
                                                  iconURL: conversation.interlocutor?.avatar?.fileURL,
                                                  iconImage: UIImage(named: "user_placeholder"))
                self?.bubbleNotifManager.showBubble(data, duration: 3)
            }
        } else {
            // Old chat cannot retrieve chat because it would mark messages as read.
            let action = UIAction(interface: .Text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                self?.openTab(.Chats, force: false)
                self?.selectedTabCoordinator?.openChat(.DataIds(data: data))
                })
            let data = BubbleNotificationData(tagGroup: conversationId,
                                              text: message,
                                              action: action)
            bubbleNotifManager.showBubble(data, duration: 3)
        }
    }
}


// MARK: - Tab helper

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
    var chatHeadsHidden: Bool {
        switch self {
        case .Chats, .Sell:
            return true
        case .Home, .Categories, .Notifications, .Profile:
            return false
        }
    }
}
