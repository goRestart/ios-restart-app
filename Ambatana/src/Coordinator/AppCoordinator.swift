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
import StoreKit

enum BumpUpSource {
    case deepLink
    case promoted
}

final class AppCoordinator: NSObject, Coordinator {
    var child: Coordinator?
    var viewController: UIViewController {
        return tabBarCtl
    }
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    let tabBarCtl: TabBarController
    fileprivate let selectedTab: Variable<Tab>

    fileprivate let mainTabBarCoordinator: MainTabCoordinator
    fileprivate let notificationsTabBarCoordinator: NotificationsTabCoordinator
    fileprivate let chatsTabBarCoordinator: ChatsTabCoordinator
    fileprivate let profileTabBarCoordinator: ProfileTabCoordinator
    fileprivate let tabCoordinators: [TabCoordinator]

    fileprivate let configManager: ConfigManager
    fileprivate let keyValueStorage: KeyValueStorage

    fileprivate let pushPermissionsManager: PushPermissionsManager
    fileprivate let ratingManager: RatingManager
    fileprivate let tracker: Tracker
    fileprivate let deepLinksRouter: DeepLinksRouter

    fileprivate let listingRepository: ListingRepository
    fileprivate let userRepository: UserRepository
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let userRatingRepository: UserRatingRepository
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager
    fileprivate let installationRepository: InstallationRepository
    fileprivate let monetizationRepository: MonetizationRepository
    fileprivate let purchasesShopper: PurchasesShopper

    fileprivate var paymentItemId: String?
    fileprivate var paymentProviderItemId: String?
    fileprivate var bumpUpSource: BumpUpSource?

    weak var delegate: AppNavigatorDelegate?

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(configManager: ConfigManager) {
        let tabBarViewModel = TabBarViewModel()
        self.init(tabBarController: TabBarController(viewModel: tabBarViewModel),
                  configManager: configManager,
                  sessionManager: Core.sessionManager,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  pushPermissionsManager: LGPushPermissionsManager.sharedInstance,
                  ratingManager: LGRatingManager.sharedInstance,
                  deepLinksRouter: LGDeepLinksRouter.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  listingRepository: Core.listingRepository,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository,
                  chatRepository: Core.chatRepository,
                  userRatingRepository: Core.userRatingRepository,
                  installationRepository: Core.installationRepository,
                  monetizationRepository: Core.monetizationRepository,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  purchasesShopper: LGPurchasesShopper.sharedInstance)
        tabBarViewModel.navigator = self
    }

    init(tabBarController: TabBarController,
         configManager: ConfigManager,
         sessionManager: SessionManager,
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         pushPermissionsManager: PushPermissionsManager,
         ratingManager: RatingManager,
         deepLinksRouter: DeepLinksRouter,
         tracker: Tracker,
         listingRepository: ListingRepository,
         userRepository: UserRepository,
         myUserRepository: MyUserRepository,
         chatRepository: ChatRepository,
         userRatingRepository: UserRatingRepository,
         installationRepository: InstallationRepository,
         monetizationRepository: MonetizationRepository,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable,
         purchasesShopper: PurchasesShopper) {

        self.tabBarCtl = tabBarController
        self.selectedTab = Variable<Tab>(.home)

        self.mainTabBarCoordinator = MainTabCoordinator()
        self.notificationsTabBarCoordinator = NotificationsTabCoordinator()
        self.chatsTabBarCoordinator = ChatsTabCoordinator()
        self.profileTabBarCoordinator = ProfileTabCoordinator()
        self.tabCoordinators = [mainTabBarCoordinator, notificationsTabBarCoordinator, chatsTabBarCoordinator,
                                profileTabBarCoordinator]

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager
        self.tracker = tracker

        self.deepLinksRouter = deepLinksRouter

        self.listingRepository = listingRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.userRatingRepository = userRatingRepository
        self.installationRepository = installationRepository
        self.monetizationRepository = monetizationRepository

        self.purchasesShopper = purchasesShopper

        self.featureFlags = featureFlags
        self.locationManager = locationManager
        super.init()

        setupTabBarController()
        setupTabCoordinators()
        setupDeepLinkingRx()
        setupCoreEventsRx()
        setupLeanplumPopUp()
    }

    func openTab(_ tab: Tab, completion: (() -> ())?) {
        openTab(tab, force: false, completion: completion)
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        // Cannot present as cannot have a parent view controller
    }
    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        // Cannot dismiss
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
    }

    private func openOnboarding() -> Bool {
        guard !keyValueStorage[.didShowOnboarding] else { return false }
        keyValueStorage[.didShowOnboarding] = true
        // If I have to show the onboarding, then I assume it is the first time the user opens the app:
        if keyValueStorage[.firstRunDate] == nil {
            keyValueStorage[.firstRunDate] = Date()
        }

        let onboardingCoordinator = OnboardingCoordinator()
        onboardingCoordinator.delegate = self
        openChild(coordinator: onboardingCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
        return true
    }

    func openForceUpdateAlertIfNeeded() {
        guard configManager.shouldForceUpdate else { return }

        let application = UIApplication.shared

        guard let url = URL(string: Constants.appStoreURL) else { return }
        guard application.canOpenURL(url) else { return }

        let alert = UIAlertController(title: LGLocalizedString.forcedUpdateTitle,
                                      message: LGLocalizedString.forcedUpdateMessage, preferredStyle: .alert)
        let openAppStore = UIAlertAction(title: LGLocalizedString.forcedUpdateUpdateButton, style: .default) { _ in
            application.openURL(url)
        }
        alert.addAction(openAppStore)
        tabBarCtl.present(alert, animated: true, completion: nil)
    }

    func openHome() {
        openTab(.home, completion: nil)
    }

    func openSell(source: PostingSource, postCategory: PostCategory?) {
        let forcedInitialTab: PostListingViewController.Tab?
        switch source {
        case .tabBar, .sellButton, .deepLink, .notifications, .deleteListing:
            forcedInitialTab = nil
        case .onboardingButton, .onboardingCamera:
            forcedInitialTab = .camera
        }

        let sellCoordinator = SellCoordinator(source: source,
                                              postCategory: postCategory,
                                              forcedInitialTab: forcedInitialTab)
        sellCoordinator.delegate = self
        openChild(coordinator: sellCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    // MARK: App Review

    func openAppRating(_ source: EventParameterRatingSource) {
        guard ratingManager.shouldShowRating else { return }
        let trackerEvent = TrackerEvent.appRatingStart(source)
        tracker.trackEvent(trackerEvent)
        if featureFlags.inAppRatingIOS10, #available(iOS 10.3, *) {
            switch source {
            case .markedSold:
                SKStoreReviewController.requestReview()
                trackUserDidRate(nil)
                LGRatingManager.sharedInstance.userDidRate()
            case .chat, .favorite, .listingSellComplete:
                guard canOpenAppStoreWriteReviewWebsite() else { return }
                askUserIsEnjoyingLetgo()
            }
        } else {
            tabBarCtl.showAppRatingView(source)
        }
    }

    func openPromoteBumpForListingId(listingId: String, purchaseableProduct: PurchaseableProduct) {

        let promoteBumpCoordinator = PromoteBumpCoordinator(listingId: listingId, purchaseableProduct: purchaseableProduct)
        promoteBumpCoordinator.delegate = self
        openChild(coordinator: promoteBumpCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    private func askUserIsEnjoyingLetgo() {
        let yesButtonInterface = UIActionInterface.image(UIImage(named: "ic_emoji_yes"), nil)
        let rateAppAlertAction = UIAction(interface: yesButtonInterface, action: { [weak self] in
            self?.askUserToRateApp(.happy)
        })
        let noButtonInterface = UIActionInterface.image(UIImage(named: "ic_emoji_no"), nil)
        let feedbackAlertAction = UIAction(interface: noButtonInterface, action: { [weak self] in
            self?.askUserToRateApp(.sad)
        })
        let dismissAction: (() -> ()) = { [weak self] in
            self?.trackUserDidRemindLater()
            LGRatingManager.sharedInstance.userDidRemindLater()
        }
        openTransitionAlert(title: LGLocalizedString.ratingAppEnjoyingAlertTitle,
                            text: "",
                            alertType: .plainAlert,
                            buttonsLayout: .emojis,
                            actions: [feedbackAlertAction, rateAppAlertAction],
                            simulatePushTransitionOnDismiss: true,
                            dismissAction: dismissAction)
    }

    private func askUserToRateApp(_ reason: EventParameterUserDidRateReason?) {
        let rateAppInterface = UIActionInterface.button(LGLocalizedString.ratingAppRateAlertYesButton,
                                                        ButtonStyle.primary(fontSize: .medium))
        let rateAppAction = UIAction(interface: rateAppInterface, action: { [weak self] in
            self?.openAppStoreWriteReviewWebsite()
            self?.trackUserDidRate(reason)
            LGRatingManager.sharedInstance.userDidRate()
        })

        let dismissAction: (() -> ()) = { [weak self] in
            self?.trackUserDidRemindLater()
            LGRatingManager.sharedInstance.userDidRemindLater()
        }
        let exitInterface = UIActionInterface.button(LGLocalizedString.ratingAppRateAlertNoButton,
                                                     ButtonStyle.secondary(fontSize: .medium,
                                                                           withBorder: true))
        let exitAction = UIAction(interface: exitInterface, action: {
            dismissAction()
        })
        openTransitionAlert(title: LGLocalizedString.ratingAppRateAlertTitle,
                            text: "",
                            alertType: .plainAlert,
                            buttonsLayout: .vertical,
                            actions: [rateAppAction, exitAction],
                            simulatePushTransitionOnPresent: true,
                            dismissAction: dismissAction)
    }

    private func canOpenAppStoreWriteReviewWebsite() -> Bool {
        if let url = URL(string: Constants.appStoreWriteReviewURL) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    private func openAppStoreWriteReviewWebsite() {
        if let url = URL(string: Constants.appStoreWriteReviewURL) {
            UIApplication.shared.openURL(url)
        }
    }

    private func trackUserDidRate(_ reason: EventParameterUserDidRateReason?) {
        let trackerEvent = TrackerEvent.appRatingRate(reason: reason)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    private func trackUserDidRemindLater() {
        let event = TrackerEvent.appRatingRemindMeLater()
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    private func openGiveFeedback() {
        guard let email = myUserRepository.myUser?.email,
            let installation = installationRepository.installation,
            let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: email, installation: installation, listing: nil) else {
                return
        }
        viewController.openInternalUrl(contactURL)
    }

    private func openTransitionAlert(title: String?,
                                     text: String,
                                     alertType: AlertType,
                                     buttonsLayout: AlertButtonsLayout,
                                     actions: [UIAction]?,
                                     simulatePushTransitionOnPresent: Bool = false,
                                     simulatePushTransitionOnDismiss: Bool = false,
                                     dismissAction: (() -> ())? = nil) {

        guard let alert = LGAlertViewController(title: title,
                                                text: text,
                                                alertType: alertType,
                                                buttonsLayout: buttonsLayout,
                                                actions: actions,
                                                dismissAction: dismissAction) else { return }
        alert.simulatePushTransitionOnPresent = simulatePushTransitionOnPresent
        alert.simulatePushTransitionOnDismiss = simulatePushTransitionOnDismiss
        tabBarCtl.present(alert, animated: false, completion: nil)
    }

    // MARK -

    func openUserRating(_ source: RateUserSource, data: RateUserData) {
        let userRatingCoordinator = UserRatingCoordinator(source: source, data: data)
        userRatingCoordinator.delegate = self
        openChild(coordinator: userRatingCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    func openChangeLocation() {
        profileTabBarCoordinator.openEditLocation(withDistanceRadius: nil)
    }

    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        let viewModel = VerifyAccountsViewModel(verificationTypes: types, source: source, completionBlock: completionBlock)
        let viewController = VerifyAccountsViewController(viewModel: viewModel)
        tabBarCtl.present(viewController, animated: true, completion: nil)
    }

    func openResetPassword(_ token: String) {
        let changePasswordCoordinator = ChangePasswordCoordinator(token: token)
        if let onboardingCoordinator = child as? ChangePasswordPresenter {
            onboardingCoordinator.openChangePassword(coordinator: changePasswordCoordinator)
            return
        }

        openChild(coordinator: changePasswordCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    func openSurveyIfNeeded() {
        delay(3) { [weak self] in
            guard let surveysCoordinator = SurveysCoordinator() else { return }
            guard let parent = self?.tabBarCtl else { return }
            surveysCoordinator.delegate = self
            self?.openChild(coordinator: surveysCoordinator, parent: parent, animated: true, forceCloseChild: false, completion: nil)
        }
    }

    func openAppInvite() {
        AppShareViewController.showOnViewControllerIfNeeded(tabBarCtl)
    }

    func canOpenAppInvite() -> Bool {
        return AppShareViewController.canBeShown()
    }

    func openDeepLink(deepLink: DeepLink) {
        triggerDeepLink(deepLink, initialDeepLink: false)
    }

    func openAppStore() {
        if let url = URL(string: Constants.appStoreURL) {
            UIApplication.shared.openURL(url)
        }
    }
}


// MARK: - SellCoordinatorDelegate

extension AppCoordinator: SellCoordinatorDelegate {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator) {}

    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing) {
        refreshSelectedListingsRefreshable()
        openAfterSellDialogIfNeeded(forListing: listing)
    }
}


// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinator: OnboardingCoordinatorDelegate {

    func onboardingCoordinatorDidFinishTour(_ coordinator: OnboardingCoordinator) {
        if let pendingDeepLink = deepLinksRouter.consumeInitialDeepLink() {
            openDeepLink(deepLink: pendingDeepLink)
        } else {
            openHome()
        }
    }

    func shouldSkipPostingTour() -> Bool {
        return deepLinksRouter.initialDeeplinkAvailable
    }

    func onboardingCoordinator(_ coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?) {
        delegate?.appNavigatorDidOpenApp()
        if let source = source, posting {
            openSell(source: source, postCategory: nil)
        } else {
            openHome()
        }
    }
}


// MARK: - UserRatingCoordinatorDelegate

extension AppCoordinator: UserRatingCoordinatorDelegate {
    func userRatingCoordinatorDidCancel() {}

    func userRatingCoordinatorDidFinish(withRating rating: Int?, ratedUserId: String?) {
        if rating == 5 {
            openAppRating(.chat)
        }
    }
}

fileprivate extension AppCoordinator {
    func refreshSelectedListingsRefreshable() {
        guard let selectedVC = tabBarCtl.selectedViewController else { return }
        guard let refreshable = topViewControllerInController(selectedVC) as? ListingsRefreshable else { return }
        refreshable.listingsRefresh()
    }

    func openAfterSellDialogIfNeeded(forListing listing: Listing) {
        if let listingId = listing.objectId, shouldRetrieveBumpeableInfo() {
            bumpUpSource = .promoted
            retrieveBumpeableInfoForListing(listingId: listingId)
        } else {
            showAfterSellPushAndRatingDialogs()
        }
    }

    func shouldRetrieveBumpeableInfo() -> Bool {
        guard featureFlags.promoteBumpUpAfterSell.isActive else { return false }
        if let lastShownDate = keyValueStorage[.lastShownPromoteBumpDate],
            abs(lastShownDate.timeIntervalSinceNow) < Constants.promoteAfterPostWaitTime {
            return false
        } else {
            return true
        }
    }

    func showAfterSellPushAndRatingDialogs() {
        if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.sell) {
            pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .sell, completion: nil)
        } else if ratingManager.shouldShowRating {
            openAppRating(.listingSellComplete)
        }
    }

    fileprivate func retrieveBumpeableInfoForListing(listingId: String) {
        purchasesShopper.bumpInfoRequesterDelegate = self
        monetizationRepository.retrieveBumpeableListingInfo(
            listingId: listingId,
            withPriceDifferentiation: featureFlags.bumpUpPriceDifferentiation.isActive) { [weak self] result in
                guard let strongSelf = self else { return }

                if let value = result.value {
                    let paymentItems = value.paymentItems.filter { $0.provider == .apple }
                    if !paymentItems.isEmpty {
                        // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                        strongSelf.paymentItemId = paymentItems.first?.itemId
                        strongSelf.paymentProviderItemId = paymentItems.first?.providerItemId

                        // if "paymentItemId" is nil, the banner creation will fail, so we check this here to avoid
                        // a useless request to apple
                        if let _ = strongSelf.paymentItemId {
                            strongSelf.purchasesShopper.productsRequestStartForListing(listingId, withIds: paymentItems.map { $0.providerItemId })
                        }
                    }
                }
        }
    }
}


// MARK: - TabCoordinatorDelegate

extension AppCoordinator: TabCoordinatorDelegate {
    func tabCoordinator(_ tabCoordinator: TabCoordinator, setSellButtonHidden hidden: Bool, animated: Bool) {
        tabBarCtl.setSellFloatingButtonHidden(hidden, animated: animated)
    }
}


// MARK: - UITabBarControllerDelegate

extension AppCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          shouldSelect viewController: UIViewController) -> Bool {

        defer {
            chatsTabBarCoordinator.setNeedsRefreshConversations()
        }

        let topVC = topViewControllerInController(viewController)
        let selectedViewController = tabBarController.selectedViewController


        if let scrollableToTop = topVC as? ScrollableToTop, selectedViewController == viewController {
            scrollableToTop.scrollToTop()
        }

        guard let tab = tabAtController(viewController) else { return false }
        let shouldOpenLogin = tab.logInRequired && !sessionManager.loggedIn
        let afterLogInSuccessful: () -> ()

        switch tab {
        case .home, .notifications, .chats, .profile:
            afterLogInSuccessful = { [weak self] in self?.openTab(tab, force: true, completion: nil) }
        case .sell:
            afterLogInSuccessful = { [weak self] in self?.openSell(source: .tabBar, postCategory: nil) }
        }

        if let source = tab.logInSource, shouldOpenLogin {
            openLogin(.fullScreen, source: source, afterLogInSuccessful: afterLogInSuccessful, cancelAction: nil)
            return false
        } else {
            switch tab {
            case .home, .notifications, .chats, .profile:
                // tab is changed after returning from this method
                return !shouldOpenLogin
            case .sell:
                openSell(source: .tabBar, postCategory: nil)
                return false
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tab = tabAtController(viewController) else { return }
        selectedTab.value = tab
    }
}


// MARK: - Private methods
// MARK: > Setup / tear down


fileprivate extension AppCoordinator {

    func setupTabBarController() {
        tabBarCtl.delegate = self
        var viewControllers = tabCoordinators.map { $0.navigationController as UIViewController }
        viewControllers.insert(UIViewController(), at: 2)  // Sell
        tabBarCtl.viewControllers = viewControllers
        tabBarCtl.setupTabBarItems()
    }

    func setupTabCoordinators() {
        mainTabBarCoordinator.tabCoordinatorDelegate = self
        notificationsTabBarCoordinator.tabCoordinatorDelegate = self
        chatsTabBarCoordinator.tabCoordinatorDelegate = self
        profileTabBarCoordinator.tabCoordinatorDelegate = self

        mainTabBarCoordinator.appNavigator = self
        notificationsTabBarCoordinator.appNavigator = self
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

    func setupCoreEventsRx() {
        sessionManager.sessionEvents.bindNext { [weak self] event in
            switch event {
            case .login:
                break
            case let .logout(kickedOut):
                self?.openTab(.home) { [weak self] in
                    if kickedOut {
                        self?.tabBarCtl.showAutoFadingOutMessageAlert(LGLocalizedString.toastErrorInternal)
                    }
                }
            }
            }.addDisposableTo(disposeBag)

        locationManager.locationEvents.filter { $0 == .movedFarFromSavedManualLocation }.take(1).bindNext {
            [weak self] _ in
            self?.askUserToUpdateLocation()
            }.addDisposableTo(disposeBag)

        locationManager.locationEvents.filter { $0 == .locationUpdate }.take(1).bindNext {
            [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.featureFlags.locationRequiresManualChangeSuggestion {
                strongSelf.askUserToUpdateLocationManually()
            }
            }.addDisposableTo(disposeBag)
    }

    func askUserToUpdateLocation() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .styledText(LGLocalizedString.commonOk, .standard), action: { [weak self] in
            self?.locationManager.setAutomaticLocation(nil)
        })
        navCtl.showAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: LGLocalizedString.commonCancel, actions: [yesAction])
    }

    func askUserToUpdateLocationManually() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .styledText(LGLocalizedString.commonOk, .standard), action: { [weak self] in
            self?.openLoginIfNeeded(from: .profile) { [weak self] in
                self?.openTab(.profile) { [weak self] in
                    self?.openChangeLocation()
                }
            }
        })
        navCtl.showAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: LGLocalizedString.commonCancel, actions: [yesAction])
    }

    func openLoginIfNeeded(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void)) {
        openLoginIfNeeded(from: from, style: .fullScreen, loggedInAction: loggedInAction, cancelAction: nil)
    }
}


// MARK: - CustomLeanplumPresenter

extension AppCoordinator: CustomLeanplumPresenter {

    func setupLeanplumPopUp() {
        Leanplum.customLeanplumAlert(self)
    }

    func showLeanplumAlert(_ title: String?, text: String, image: String, action: UIAction) {
        let alertIcon = UIImage(contentsOfFile: image)
        guard let alert = LGAlertViewController(title: title, text: text, alertType: .iconAlert(icon: alertIcon), actions: [action]) else { return }
        tabBarCtl.present(alert, animated: true, completion: nil)
    }
}


// MARK: > Helper

fileprivate extension AppCoordinator {
    func shouldOpenTab(_ tab: Tab) -> Bool {
        guard let vc = controllerAtTab(tab) else { return false }
        return tabBarController(tabBarCtl, shouldSelect: vc)
    }

    func controllerAtTab(_ tab: Tab) -> UIViewController? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        guard 0..<vcs.count ~= tab.index else { return nil }
        return vcs[tab.index]
    }

    func tabAtController(_ controller: UIViewController) -> Tab? {
        guard let vcs = tabBarCtl.viewControllers else { return nil }
        let vc = controller.navigationController ?? controller
        guard let index = vcs.index(of: vc) else { return nil }
        return Tab(index: index, featureFlags: featureFlags)
    }

    func topViewControllerInController(_ controller: UIViewController) -> UIViewController {
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

fileprivate extension AppCoordinator {

    func openTab(_ tab: Tab, force: Bool, completion: (() -> Void)?) {
        guard force || shouldOpenTab(tab) else { return }

        let openCompletion: () -> Void = { [weak self] in
            self?.tabBarCtl.clearAllPresented {
                self?.tabBarCtl.switchTo(tab: tab)
                completion?()
            }
        }
        if let child = child {
            child.closeCoordinator(animated: false, completion: openCompletion)
        } else if let child = selectedTabCoordinator?.child {
            child.closeCoordinator(animated: false, completion: openCompletion)
        } else {
            openCompletion()
        }
    }

    func openLogin(_ style: LoginStyle, source: EventParameterLoginSourceValue, afterLogInSuccessful: @escaping () -> (),
                   cancelAction: (() -> Void)?) {
        let coordinator = LoginCoordinator(source: source, style: style, loggedInAction: afterLogInSuccessful,
                                           cancelAction: cancelAction)
        openChild(coordinator: coordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    /**
     Those links will always come from an inactive state of the app. So it means the user clicked a push, a link or a
     shortcut.
     As it was a user action we must perform navigation
     */
    func openExternalDeepLink(_ deepLink: DeepLink, initialDeepLink: Bool = false) {
        let event = TrackerEvent.openAppExternal(deepLink.campaign, medium: deepLink.medium, source: deepLink.source)
        tracker.trackEvent(event)

        triggerDeepLink(deepLink, initialDeepLink: initialDeepLink)
    }

    func triggerDeepLink(_ deepLink: DeepLink, initialDeepLink: Bool) {
        var afterDelayClosure: (() -> Void)?
        switch deepLink.action {
        case .home:
            afterDelayClosure = { [weak self] in
                self?.openTab(.home, force: false, completion: nil)
            }
        case .sell:
            afterDelayClosure = { [weak self] in
                self?.openSell(source: .deepLink, postCategory: nil)
            }
        case let .listing(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId), source: .openApp,
                                                          actionOnFirstAppear: .nonexistent)
            }
        case let .listingShare(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId), source: .openApp,
                                                          actionOnFirstAppear: .showShareSheet)
            }
        case let .listingBumpUp(listingId):
            bumpUpSource = .deepLink
            retrieveBumpeableInfoForListing(listingId: listingId)
        case let .listingMarkAsSold(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.openTab(.profile, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId),
                                                              source: .openApp, actionOnFirstAppear: .triggerMarkAsSold)
                }
            }
        case let .user(userId):
            if userId == myUserRepository.myUser?.objectId {
                openTab(.profile, force: false, completion: nil)
            } else {
                tabBarCtl.clearAllPresented(nil)
                afterDelayClosure = { [weak self] in
                    self?.selectedTabCoordinator?.openUser(UserDetailData.id(userId: userId, source: .link))
                }
            }
        case .conversations:
            openTab(.chats, force: false, completion: nil)
        case let .conversation(conversationId):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(conversationId: conversationId), source: .external,
                                                          predefinedMessage: nil)
                }
            }
        case let .conversationWithMessage(conversationId: conversationId, message: message):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(conversationId: conversationId), source: .external,
                                                          predefinedMessage: message)
                }
            }
        case .message(_, let conversationId):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(conversationId: conversationId), source: .external,
                                                          predefinedMessage: nil)
                }
            }
        case .search(let query, let categories):
            afterDelayClosure = { [weak self] in
                self?.openTab(.home, force: false) { [weak self] in
                    self?.mainTabBarCoordinator.openSearch(query, categoriesString: categories)
                }
            }
        case .resetPassword(let token):
            afterDelayClosure = { [weak self] in
                self?.openResetPassword(token)
            }
        case .userRatings:
            afterDelayClosure = { [weak self] in
                self?.openTab(.profile) { [weak self] in
                    self?.openMyUserRatings()
                }
            }
        case let .userRating(ratingId):
            afterDelayClosure = { [weak self] in
                self?.openTab(.profile) { [weak self] in
                    self?.openUserRatingForUserFromRating(ratingId)
                }
            }
        case .notificationCenter:
            openTab(.notifications, force: false, completion: nil)
        case .appStore:
            afterDelayClosure = { [weak self] in
                self?.openAppStore()
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
    func showInappDeepLink(_ deepLink: DeepLink) {
        //Avoid showing inapp notification when selling
        if let child = child, child is SellCoordinator { return }

        switch deepLink.action {
        case .home, .sell, .listing, .listingShare, .listingBumpUp, .listingMarkAsSold, .user, .conversations, .conversationWithMessage, .search, .resetPassword, .userRatings, .userRating, .notificationCenter, .appStore:
        return // Do nothing
        case let .conversation(data):
            showInappChatNotification(data, message: deepLink.origin.message)
        case .message(_, let data):
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

    func openMyUserRatings() {
        guard let navCtl = selectedNavigationController else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        let viewModel = UserRatingListViewModel(userId: myUserId, tabNavigator: profileTabBarCoordinator)

        let hidesBottomBarWhenPushed = navCtl.viewControllers.count == 1
        let viewController = UserRatingListViewController(viewModel: viewModel,
                                                          hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navCtl.pushViewController(viewController, animated: true)
    }

    func openUserRatingForUserFromRating(_ ratingId: String) {
        guard let navCtl = selectedNavigationController else { return }

        navCtl.showLoadingMessageAlert()
        userRatingRepository.show(ratingId) { [weak self] result in
            if let rating = result.value, let data = RateUserData(user: rating.userFrom) {
                navCtl.dismissLoadingMessageAlert {
                    self?.openUserRating(.deepLink, data: data)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError:
                    message = LGLocalizedString.commonUserReviewNotAvailable
                }
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func showInappChatNotification(_ conversationId: String, message: String) {
        guard sessionManager.loggedIn else { return }
        //Avoid showing notification if user is already in that conversation.
        guard let selectedTabCoordinator = selectedTabCoordinator, !selectedTabCoordinator.isShowingConversation(conversationId) else { return }

        tracker.trackEvent(TrackerEvent.inappChatNotificationStart())
        chatRepository.showConversation(conversationId) { [weak self] result in
            guard let conversation = result.value else { return }
            let action = UIAction(interface: .text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openChat(.conversation(conversation: conversation), source: .inAppNotification, predefinedMessage: nil)
                }
            })
            let data = BubbleNotificationData(tagGroup: conversationId,
                                              text: message,
                                              action: action,
                                              iconURL: conversation.interlocutor?.avatar?.fileURL,
                                              iconImage: UIImage(named: "user_placeholder"))
            self?.showBubble(with: data, duration: Constants.bubbleChatDuration)
        }
    }
}

extension AppCoordinator: ChangePasswordNavigator {
    func closeChangePassword() {
        tabBarCtl.dismiss(animated: true, completion: nil)
    }
    func passwordSaved() {
        tabBarCtl.dismiss(animated: true, completion: nil)
    }
}

extension AppCoordinator: BumpInfoRequesterDelegate {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?, withProducts products: [PurchaseableProduct]) {

        guard let requestListingId = listingId, let purchase = products.first, let bumpUpSource = bumpUpSource else { return }

        switch bumpUpSource {
        case .deepLink:
            tabBarCtl.clearAllPresented(nil)
            openTab(.profile, force: false) { [weak self] in
                let triggerBumpOnAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(purchaseableProduct: purchase,
                                                                                           paymentItemId: self?.paymentItemId,
                                                                                           paymentProviderItemId: self?.paymentProviderItemId,
                                                                                           bumpUpType: .priced,
                                                                                           triggerBumpUpSource: .deepLink)
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: requestListingId),
                                                          source: .openApp, actionOnFirstAppear: triggerBumpOnAppear)
            }
        case .promoted:
            tabBarCtl.clearAllPresented(nil)

            let promoteBumpEvent = TrackerEvent.bumpUpPromo()
            tracker.trackEvent(promoteBumpEvent)

            openPromoteBumpForListingId(listingId: requestListingId, purchaseableProduct: purchase)
        }
    }
}

extension AppCoordinator: PromoteBumpCoordinatorDelegate {
    func openSellFasterForListingId(listingId: String, purchaseableProduct: PurchaseableProduct) {
        tabBarCtl.clearAllPresented(nil)
        openTab(.profile, force: false) { [weak self] in

            let triggerBumpOnAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(purchaseableProduct: purchaseableProduct,
                                                                                       paymentItemId: self?.paymentItemId,
                                                                                       paymentProviderItemId: self?.paymentProviderItemId,
                                                                                       bumpUpType: .priced, triggerBumpUpSource: .promoted)

            self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId),
                                                      source: .promoteBump,
                                                      actionOnFirstAppear: triggerBumpOnAppear)
            self?.keyValueStorage[.lastShownPromoteBumpDate] = Date()
            
        }
    }
}


// MARK: - Tab helper

fileprivate extension Tab {
    var logInRequired: Bool {
        switch self {
        case .home, .sell:
            return false
        case .notifications, .chats, .profile:
            return true
        }
    }
    var logInSource: EventParameterLoginSourceValue? {
        switch self {
        case .home:
            return nil
        case .notifications:
            return .notifications
        case .sell:
            return .sell
        case .chats:
            return .chats
        case .profile:
            return .profile
        }
    }
}
