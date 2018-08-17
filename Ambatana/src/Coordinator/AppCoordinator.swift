import LGCoreKit
import RxSwift
import UIKit
import StoreKit
import LGComponents

enum BumpUpSource {
    case deepLink
    case promoted
    case edit(listing: Listing)
    case sellEdit(listing: Listing)
    case profile

    var typePageParameter: EventParameterTypePage? {
        switch self {
        case .deepLink:
            return .notificationCenter
        case .promoted:
            return .sell
        case .edit:
            return .edit
        case .sellEdit:
            return .sellEdit
        case .profile:
            return .profile
        }
    }
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
    fileprivate let communityTabCoordinator: CommunityTabCoordinator
    fileprivate let tabCoordinators: [TabCoordinator]

    fileprivate let configManager: ConfigManager
    fileprivate let keyValueStorage: KeyValueStorage

    fileprivate let pushPermissionsManager: PushPermissionsManager
    fileprivate let ratingManager: RatingManager
    fileprivate let tracker: Tracker
    fileprivate let deepLinksRouter: DeepLinksRouter
    fileprivate let deeplinkMailBox: DeepLinkMailBox

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

    fileprivate var bumpUpSource: BumpUpSource?
    fileprivate var timeSinceLastBump: TimeInterval?
    fileprivate var offensiveReportAlertWidth: CGFloat = 310

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
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance,
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
         deeplinkMailBox: DeepLinkMailBox,
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
        self.communityTabCoordinator = CommunityTabCoordinator(source: .tabbar)

        if featureFlags.community.shouldShowOnTab {
            self.tabCoordinators = [mainTabBarCoordinator, notificationsTabBarCoordinator, chatsTabBarCoordinator,
                                    communityTabCoordinator]
        } else {
            self.tabCoordinators = [mainTabBarCoordinator, notificationsTabBarCoordinator, chatsTabBarCoordinator,
                                    profileTabBarCoordinator]
        }

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.bubbleNotificationManager = bubbleNotificationManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager
        self.tracker = tracker

        self.deepLinksRouter = deepLinksRouter
        self.deeplinkMailBox = deeplinkMailBox

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

        self.profileTabBarCoordinator.profileCoordinatorSearchAlertsDelegate = self

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

        guard let url = URL(string: SharedConstants.appStoreURL) else { return }
        guard application.canOpenURL(url) else { return }

        let alert = UIAlertController(title: R.Strings.forcedUpdateTitle,
                                      message: R.Strings.forcedUpdateMessage, preferredStyle: .alert)
        let openAppStore = UIAlertAction(title: R.Strings.forcedUpdateUpdateButton, style: .default) { _ in
            application.openURL(url)
        }
        alert.addAction(openAppStore)
        tabBarCtl.present(alert, animated: true, completion: nil)
    }

    func openHome() {
        openTab(.home, completion: nil)
    }

    func openSell(source: PostingSource, postCategory: PostCategory?, listingTitle: String?) {
        let forcedInitialTab: PostListingViewController.Tab?
        switch source {
        case .tabBar, .listingList, .profile, .deepLink, .notifications, .deleteListing, .realEstatePromo, .chatList:
            forcedInitialTab = nil
        case .onboardingButton, .onboardingCamera, .onboardingBlockingPosting:
            forcedInitialTab = .camera
        }

        let sellCoordinator = SellCoordinator(source: source,
                                              postCategory: postCategory,
                                              forcedInitialTab: forcedInitialTab,
                                              listingTitle: listingTitle)
        sellCoordinator.delegate = self
        openChild(coordinator: sellCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }
    
    func showBottomBubbleNotification(data: BubbleNotificationData,
                                      duration: TimeInterval,
                                      alignment: BubbleNotificationView.Alignment,
                                      style: BubbleNotificationView.Style) {
        tabBarCtl.showBottomBubbleNotification(data: data, duration: duration, alignment: alignment, style: style)
    }
    
    
    // MARK: App Review

    func openAppRating(_ source: EventParameterRatingSource) {
        guard ratingManager.shouldShowRating else { return }
        
        if #available(iOS 10.3, *) {
            switch source {
            case .markedSold:
                trackUserRateStart(source)
                SKStoreReviewController.requestReview()
                trackUserDidRate(nil)
                LGRatingManager.sharedInstance.userDidRate()
            case .chat, .favorite, .listingSellComplete:
                guard canOpenAppStoreWriteReviewWebsite() else { return }
                trackUserRateStart(source)
                askUserIsEnjoyingLetgo()
            }
        } else {
            trackUserRateStart(source)
            tabBarCtl.showAppRatingView(source)
        }
    }

    func openPromoteBumpForListingId(listingId: String,
                                     bumpUpProductData: BumpUpProductData,
                                     typePage: EventParameterTypePage?) {

        let promoteBumpEvent = TrackerEvent.bumpUpPromo()
        tracker.trackEvent(promoteBumpEvent)

        let promoteBumpCoordinator = PromoteBumpCoordinator(listingId: listingId,
                                                            bumpUpProductData: bumpUpProductData,
                                                            typePage: typePage)
        promoteBumpCoordinator.delegate = self
        openChild(coordinator: promoteBumpCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    func canOpenOffensiveReportAlert() -> Bool {
        return tabBarCtl.presentedViewController == nil
    }

    func openOffensiveReportAlert() {
        guard canOpenOffensiveReportAlert() else { return }
        let reviewAction = { [weak self] in
            guard let url = LetgoURLHelper.buildCommunityGuidelineURL() else { return }
            self?.openInAppWebView(url: url)
        }
        let reviewActionInterface = UIActionInterface.button(R.Strings.offensiveReportAlertPrimaryAction,
                                                             .primary(fontSize: .medium))
        let reviewAlertAction = UIAction(interface: reviewActionInterface,
                                         action: reviewAction,
                                         accessibility: AccessibilityId.offensiveReportAlertOpenGuidelineButton)
        let skipActionInterface = UIActionInterface.button(R.Strings.offensiveReportAlertSecondaryAction,
                                                            .secondary(fontSize: .medium, withBorder: true))
        let skipAlertAction = UIAction(interface: skipActionInterface,
                                  action: {},
                                  accessibility: AccessibilityId.offensiveReportAlertSkipButton)
        if let alert = LGAlertViewController(title: R.Strings.offensiveReportAlertTitle,
                                             text: R.Strings.offensiveReportAlertMessage,
                                             alertType: .plainAlert,
                                             buttonsLayout: .vertical,
                                             actions: [reviewAlertAction, skipAlertAction],
                                             dismissAction: nil) {
            alert.alertWidth = offensiveReportAlertWidth
            tabBarCtl.present(alert, animated: true, completion: nil)
        }
    }

    private func askUserIsEnjoyingLetgo() {
        let yesButtonInterface = UIActionInterface.image(R.Asset.IconsButtons.icEmojiYes.image, nil)
        let rateAppAlertAction = UIAction(interface: yesButtonInterface, action: { [weak self] in
            self?.askUserToRateApp(.happy)
        })
        let noButtonInterface = UIActionInterface.image(R.Asset.IconsButtons.icEmojiNo.image, nil)
        let feedbackAlertAction = UIAction(interface: noButtonInterface, action: { [weak self] in
            self?.askUserToRateApp(.sad)
        })
        let dismissAction: (() -> ()) = { [weak self] in
            self?.trackUserDidRemindLater()
            LGRatingManager.sharedInstance.userDidRemindLater()
        }
        openTransitionAlert(title: R.Strings.ratingAppEnjoyingAlertTitle,
                            text: "",
                            alertType: .plainAlert,
                            buttonsLayout: .emojis,
                            actions: [feedbackAlertAction, rateAppAlertAction],
                            simulatePushTransitionOnDismiss: true,
                            dismissAction: dismissAction)
    }

    private func askUserToRateApp(_ reason: EventParameterUserDidRateReason?) {
        let rateAppInterface = UIActionInterface.button(R.Strings.ratingAppRateAlertYesButton,
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
        let exitInterface = UIActionInterface.button(R.Strings.ratingAppRateAlertNoButton,
                                                     ButtonStyle.secondary(fontSize: .medium,
                                                                           withBorder: true))
        let exitAction = UIAction(interface: exitInterface, action: {
            dismissAction()
        })
        openTransitionAlert(title: R.Strings.ratingAppRateAlertTitle,
                            text: "",
                            alertType: .plainAlert,
                            buttonsLayout: .vertical,
                            actions: [rateAppAction, exitAction],
                            simulatePushTransitionOnPresent: true,
                            dismissAction: dismissAction)
    }

    private func canOpenAppStoreWriteReviewWebsite() -> Bool {
        if let url = URL(string: SharedConstants.appStoreWriteReviewURL) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    private func openAppStoreWriteReviewWebsite() {
        if let url = URL(string: SharedConstants.appStoreWriteReviewURL) {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func trackUserRateStart(_ source: EventParameterRatingSource) {
        let trackerEvent = TrackerEvent.appRatingStart(source)
        tracker.trackEvent(trackerEvent)
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
        viewController.openInAppWebViewWith(url: contactURL)
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
        let assembly = LGRateBuilder.modal(root: tabBarCtl)
        let vc = assembly.buildRateUser(source: source, data: data, showSkipButton: false)
        tabBarCtl.present(vc, animated: true, completion: nil)
    }

    func openChangeLocation() {
        profileTabBarCoordinator.openEditLocation(withDistanceRadius: nil)
    }

    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        let viewModel = VerifyAccountsViewModel(verificationTypes: types, source: source, completionBlock: completionBlock)
        let viewController = VerifyAccountsViewController(viewModel: viewModel)
        viewController.setupForModalWithNonOpaqueBackground()
        viewController.modalTransitionStyle = .crossDissolve
        tabBarCtl.present(viewController, animated: true, completion: nil)
    }

    func openResetPassword(_ token: String) {
        let vc = LGChangePasswordBuilder.modal.buildChangePassword(withToken: token)
        tabBarCtl.present(vc, animated: true, completion: nil)
    }

    func openSurveyIfNeeded() {
        guard featureFlags.surveyEnabled else { return }
        guard !featureFlags.surveyUrl.isEmpty, let url = URL(string: featureFlags.surveyUrl) else { return }

        delay(3) { [weak self] in
            guard let tab = self?.tabBarCtl else { return }
            let assembly = LGSurveyBuilder.modal(root: tab)
            let vc = assembly.buildWebSurvey(with: url)
            tab.present(vc, animated: true, completion: nil)
        }
    }

    func openAppInvite(myUserId: String?, myUserName: String?) {
        AppShareViewController.showOnViewControllerIfNeeded(tabBarCtl, myUserId: myUserId, myUserName: myUserName)
    }

    func canOpenAppInvite() -> Bool {
        return AppShareViewController.canBeShown()
    }

    func openDeepLink(deepLink: DeepLink) {
        triggerDeepLink(deepLink, initialDeepLink: false)
    }

    func openAppStore() {
        if let url = URL(string: SharedConstants.appStoreURL) {
            UIApplication.shared.openURL(url)
        }
    }

    func openEditForListing(listing: Listing,
                            bumpUpProductData: BumpUpProductData?,
                            maxCountdown: TimeInterval) {
        let nav = UINavigationController()
        let assembly = LGListingBuilder.standard(navigationController: nav)
        let vc = assembly.buildEditView(listing: listing,
                                        pageType: nil,
                                        bumpUpProductData: bumpUpProductData,
                                        listingCanBeBoosted: false,
                                        timeSinceLastBump: nil,
                                        maxCountdown: 0,
                                        onEditAction: onEdit)
        nav.viewControllers = [vc]
        tabBarCtl.present(nav, animated: true)
    }

    private func onEdit(listing: Listing,
                           bumpData: BumpUpProductData?,
                           timeSinceLastBump: TimeInterval?,
                           maxCountdown: TimeInterval) {
        refreshSelectedListingsRefreshable()
        guard let listingId = listing.objectId, let bumpData = bumpData, bumpData.hasPaymentId else { return }
        openPromoteBumpForListingId(listingId: listingId,
                                    bumpUpProductData: bumpData,
                                    typePage: .sellEdit)
    }

    func openConfirmUsername(token: String) {
        let confirmUsernameCoordinator = PasswordlessUsernameCoordinator(token: token)
        openChild(coordinator: confirmUsernameCoordinator,
                  parent: tabBarCtl,
                  animated: true,
                  forceCloseChild: true,
                  completion: nil)
    }

    func openInAppWebView(url: URL) {
        tabBarCtl.openInAppWebViewWith(url: url)
    }

    func openCommunityTab() {
        openTab(.community, completion: nil)
    }
}

// MARK: - SellCoordinatorDelegate

extension AppCoordinator: SellCoordinatorDelegate {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator) {}

    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing) {
        refreshSelectedListingsRefreshable()
        openAfterSellDialogIfNeeded(forListing: listing, bumpUpSource: .promoted)
    }

    func sellCoordinator(_ coordinator: SellCoordinator, closePostAndOpenEditForListing listing: Listing) {
		openAfterSellDialogIfNeeded(forListing: listing, bumpUpSource: .sellEdit(listing: listing))
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
    
    func shouldShowBlockingPosting() -> Bool {
        return featureFlags.onboardingIncentivizePosting.isActive
    }

    func onboardingCoordinator(_ coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?) {
        delegate?.appNavigatorDidOpenApp()
        if let source = source, posting {
            openSell(source: source, postCategory: nil, listingTitle: nil)
            trackStartSelling(source: source)
        } else {
            openHome()
        }
    }
}

fileprivate extension AppCoordinator {
    func refreshSelectedListingsRefreshable() {
        guard let selectedVC = tabBarCtl.selectedViewController else { return }
        guard let refreshable = topViewControllerInController(selectedVC) as? ListingsRefreshable else { return }
        refreshable.listingsRefresh()
    }

    func openAfterSellDialogIfNeeded(forListing listing: Listing, bumpUpSource: BumpUpSource) {
        if let listingId = listing.objectId, shouldRetrieveBumpeableInfoFor(source: bumpUpSource) {
            self.bumpUpSource = bumpUpSource
            retrieveBumpeableInfoForListing(listingId: listingId, bumpUpSource: bumpUpSource)
        } else {
            showAfterSellPushAndRatingDialogs()
        }
    }

    fileprivate func shouldRetrieveBumpeableInfoFor(source: BumpUpSource) -> Bool {
        switch source {
        case .edit, .deepLink, .sellEdit, .profile:
            return true
        case .promoted:
            return !promoteBumpShownInLastDay
        }
    }

    fileprivate var promoteBumpShownInLastDay: Bool {
        if let lastShownDate = keyValueStorage[.lastShownPromoteBumpDate] {
            return abs(lastShownDate.timeIntervalSinceNow) < SharedConstants.promoteAfterPostWaitTime
        } else {
            return false
        }
    }

    func showAfterSellPushAndRatingDialogs() {
        if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.sell) {
            pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .sell, completion: nil)
        } else if ratingManager.shouldShowRating {
            openAppRating(.listingSellComplete)
        }
    }

    fileprivate func retrieveBumpeableInfoForListing(listingId: String, bumpUpSource: BumpUpSource) {
        purchasesShopper.bumpInfoRequesterDelegate = self
        monetizationRepository.retrieveBumpeableListingInfo(
            listingId: listingId) { [weak self] result in
                guard let strongSelf = self else { return }
                if let value = result.value {
                    let paymentItems = value.paymentItems.filter { $0.provider == .apple }
                    guard !paymentItems.isEmpty else {
                        strongSelf.bumpUpFallbackFor(source: bumpUpSource)
                        return
                    }
                    // will be considered bumpeable ONCE WE GOT THE PRICES of the products, not before.
                    strongSelf.timeSinceLastBump = value.timeSinceLastBump

                    // if "letgoItemId" is nil, we don't know the price of the bump, so we check this here to avoid
                    // a useless request to apple
                    if let letgoItemId = paymentItems.first?.itemId {
                        strongSelf.purchasesShopper.productsRequestStartForListingId(listingId,
                                                                                     letgoItemId: letgoItemId,
                                                                                     withIds: paymentItems.map { $0.providerItemId },
                                                                                     maxCountdown: value.maxCountdown,
                                                                                     typePage: bumpUpSource.typePageParameter)
                    } else {
                        strongSelf.bumpUpFallbackFor(source: bumpUpSource)
                    }
                } else {
                    strongSelf.bumpUpFallbackFor(source: bumpUpSource)
                }
        }
    }

    private func bumpUpFallbackFor(source: BumpUpSource) {
        switch source {
        case .sellEdit(let listing):
            openEditForListing(listing: listing, bumpUpProductData: nil, maxCountdown: 0)
        case .edit(let listing):
            openEditForListing(listing: listing, bumpUpProductData: nil, maxCountdown: 0)
        case .deepLink, .promoted, .profile:
            break
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
        let topVC = topViewControllerInController(viewController)
        let selectedViewController = tabBarController.selectedViewController


        if let scrollableToTop = topVC as? ScrollableToTop, selectedViewController == viewController {
            scrollableToTop.scrollToTop()
        }

        guard let tab = tabAtController(viewController) else { return false }
        let shouldOpenLogin = tab.logInRequired && !sessionManager.loggedIn
        let afterLogInSuccessful: () -> ()

        switch tab {
        case .home, .notifications, .chats, .profile, .community:
            afterLogInSuccessful = { [weak self] in self?.openTab(tab, force: true, completion: nil) }
        case .sell:
            afterLogInSuccessful = { [weak self] in
                let source: PostingSource = .tabBar
                self?.trackStartSelling(source: source)
                self?.openSell(source: source, postCategory: nil, listingTitle: nil)
            }
        }

        if let source = tab.logInSource, shouldOpenLogin {
            openLogin(.fullScreen, source: source, afterLogInSuccessful: afterLogInSuccessful, cancelAction: nil)
            return false
        } else {
            switch tab {
            case .home, .notifications, .chats, .profile, .community:
                // tab is changed after returning from this method
                return !shouldOpenLogin
            case .sell:
                let source: PostingSource = .tabBar
                openSell(source: source, postCategory: nil, listingTitle: nil)
                trackStartSelling(source: source)
                return false
            }
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tab = tabAtController(viewController) else { return }
        tabBarCtl.hideBottomBubbleNotifications()
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
        communityTabCoordinator.tabCoordinatorDelegate = self

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
            }.disposed(by: disposeBag)

        deeplinkMailBox.deeplinks
            .subscribeNext { [weak self] (deeplink) in
                self?.openDeepLink(deepLink: deeplink)
        }.disposed(by: disposeBag)
    }

    func setupCoreEventsRx() {
        sessionManager.sessionEvents.bind { [weak self] event in
            switch event {
            case .login:
                break
            case let .logout(kickedOut):
                self?.openTab(.home) { [weak self] in
                    if kickedOut {
                        self?.tabBarCtl.showAutoFadingOutMessageAlert(message: R.Strings.toastErrorInternal)
                    }
                }
            }
            }.disposed(by: disposeBag)

        locationManager.locationEvents.filter { $0 == .movedFarFromSavedManualLocation }.take(1).bind {
            [weak self] _ in
            self?.askUserToUpdateLocation()
            }.disposed(by: disposeBag)

        locationManager.locationEvents.filter { $0 == .locationUpdate }.take(1).bind {
            [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.featureFlags.locationRequiresManualChangeSuggestion {
                strongSelf.askUserToUpdateLocationManually()
            }
            }.disposed(by: disposeBag)
    }

    func askUserToUpdateLocation() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .styledText(R.Strings.commonOk, .standard), action: { [weak self] in
            self?.locationManager.setAutomaticLocation(nil)
        })
        navCtl.showAlert(nil, message: R.Strings.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: R.Strings.commonCancel, actions: [yesAction])
    }

    func askUserToUpdateLocationManually() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .styledText(R.Strings.commonOk, .standard), action: { [weak self] in
            self?.openLoginIfNeeded(from: .profile) { [weak self] in
                self?.openUserProfile() { [weak self] in
                    self?.openChangeLocation()
                }
            }
        })
        navCtl.showAlert(nil, message: R.Strings.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: R.Strings.commonCancel, actions: [yesAction])
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

    func showLPMessageAlert(_ message: LPMessage) {
        let assembly = LGLeanplumBuilder.modal(root: tabBarCtl)
        let vc = assembly.buildLeanplumMessage(with: message)
        tabBarCtl.present(vc, animated: true, completion: nil)
    }

    func closeLPMessage() {
        child?.closeCoordinator(animated: true, completion: nil)
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
        case .appRating(let source):
            if let ratingSource = EventParameterRatingSource(rawValue: source) {
                afterDelayClosure = { [weak self] in
                    self?.openAppRating(ratingSource)
                }
            }
        case .home:
            afterDelayClosure = { [weak self] in
                self?.openTab(.home, force: false, completion: nil)
            }
        case .sell:
            afterDelayClosure = { [weak self] in
                let source: PostingSource = .deepLink
                self?.trackStartSelling(source: source)
                self?.openSell(source: source, postCategory: nil, listingTitle: nil)
            }
        case let .listing(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId), source: .external,
                                                          actionOnFirstAppear: .nonexistent)
            }
        case let .listingShare(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId), source: .external,
                                                          actionOnFirstAppear: .showShareSheet)
            }
        case let .listingBumpUp(listingId):
            bumpUpSource = .deepLink
            retrieveBumpeableInfoForListing(listingId: listingId, bumpUpSource: .deepLink)
        case let .listingMarkAsSold(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.openTab(.profile, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId),
                                                              source: .external, actionOnFirstAppear: .triggerMarkAsSold)
                }
            }
        case let .listingEdit(listingId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId), source: .external,
                                                          actionOnFirstAppear: .edit)
            }
        case let .user(userId):
            if userId == myUserRepository.myUser?.objectId {
                openUserProfile()
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
                self?.openUserProfile() { [weak self] in
                    self?.openMyUserRatings()
                }
            }
        case let .userRating(ratingId):
            afterDelayClosure = { [weak self] in
                self?.openUserProfile() { [weak self] in
                    self?.openUserRatingForUserFromRating(ratingId)
                }
            }
        case .notificationCenter:
            openTab(.notifications, force: false, completion: nil)
        case .appStore:
            afterDelayClosure = { [weak self] in
                self?.openAppStore()
            }
        case .passwordlessSignup(let token):
            afterDelayClosure = { [weak self] in
                self?.openConfirmUsername(token: token)
            }
        case .passwordlessLogin(let token):
            afterDelayClosure = { [weak self] in
                self?.loginPasswordlessWith(token: token)
            }
        case .webView(let url):
            afterDelayClosure = { [weak self] in
                self?.openInAppWebView(url: url)
            }
        }

        if let afterDelayClosure = afterDelayClosure {
            delay(0.5) { 
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
        case .home, .sell, .listing, .listingShare, .listingBumpUp, .listingMarkAsSold, .listingEdit, .user,
             .conversations, .conversationWithMessage, .search, .resetPassword, .userRatings, .userRating,
             .notificationCenter, .appStore, .passwordlessLogin, .passwordlessSignup, .webView, .appRating:
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
            if let rating = result.value, let data = RateUserData(user: rating.userFrom, listingId: rating.listingId, ratingType: rating.type.rateBackType) {
                navCtl.dismissLoadingMessageAlert {
                    self?.openUserRating(.deepLink, data: data)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
                    message = R.Strings.commonErrorConnectionFailed
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError,
                     .wsChatError, .searchAlertError:
                    message = R.Strings.commonUserReviewNotAvailable
                }
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message: message)
                }
            }
        }
    }

    func loginPasswordlessWith(token: String) {
        guard let navCtl = selectedNavigationController else { return }
        navCtl.showLoadingMessageAlert()

        sessionManager.loginPasswordlessWith(token: token) { result in
            switch result {
            case .success:
                navCtl.dismissLoadingMessageAlert()
            case .failure:
                let message = R.Strings.commonErrorGenericBody // FIXME: change when product specs are available
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message: message)
                }
            }
        }
    }
    
    func openUserProfile(completion: (()->Void)? = nil) {
        if featureFlags.community.shouldShowOnTab {
            let coord = ProfileTabCoordinator(source: .mainListing)
            openChild(coordinator: coord, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: completion)
        } else {
            openTab(.profile, force: false, completion: completion)
        }
    }

    func showInappChatNotification(_ conversationId: String, message: String) {
        guard sessionManager.loggedIn else { return }
        //Avoid showing notification if user is already in that conversation.
        guard let selectedTabCoordinator = selectedTabCoordinator, !selectedTabCoordinator.isShowingConversation(conversationId) else { return }

        tracker.trackEvent(TrackerEvent.inappChatNotificationStart())
        chatRepository.showConversation(conversationId) { [weak self] result in
            guard let conversation = result.value else { return }
            let action = UIAction(interface: .text(R.Strings.appNotificationReply), action: { [weak self] in
                self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openChat(.conversation(conversation: conversation), source: .inAppNotification, predefinedMessage: nil)
                }
            })
            let data = BubbleNotificationData(tagGroup: conversationId,
                                              text: message,
                                              action: action,
                                              iconURL: conversation.interlocutor?.avatar?.fileURL,
                                              iconImage: R.Asset.IconsButtons.userPlaceholder.image)
            self?.showBubble(with: data, duration: SharedConstants.bubbleChatDuration)
        }
    }

    // MARK: - Trackings

    private func trackStartSelling(source: PostingSource) {
        tracker.trackEvent(TrackerEvent.listingSellStart(typePage: source.typePage,
                                                         buttonName: source.buttonName,
                                                         sellButtonPosition: source.sellButtonPosition,
                                                         category: nil))
    }

    private func trackSelectCategory(source: PostingSource, category: PostCategory) {
        tracker.trackEvent(TrackerEvent.listingSellCategorySelect(typePage: source.typePage,
                                                                  postingType: EventParameterPostingType(category: category),
                                                                  category: category.listingCategory))
    }
}

extension AppCoordinator: BumpInfoRequesterDelegate {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?,
                                                    withProducts products: [PurchaseableProduct],
                                                    letgoItemId: String?,
                                                    storeProductId: String?,
                                                    maxCountdown: TimeInterval,
                                                    typePage: EventParameterTypePage?) {
        guard let requestListingId = listingId, let purchase = products.first, let bumpUpSource = bumpUpSource else { return }

        let bumpUpProductData = BumpUpProductData(bumpUpPurchaseableData: .purchaseableProduct(product: purchase),
                                                  letgoItemId: letgoItemId,
                                                  storeProductId: storeProductId)
        switch bumpUpSource {
        case .deepLink, .profile:
            tabBarCtl.clearAllPresented(nil)
            openUserProfile() { [weak self] in
                var actionOnFirstAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(bumpUpProductData: bumpUpProductData,
                                                                                           bumpUpType: .priced,
                                                                                           triggerBumpUpSource: .deepLink,
                                                                                           typePage: .notificationCenter)
                if let timeSinceLastBump = self?.timeSinceLastBump, timeSinceLastBump > 0 {
                    actionOnFirstAppear = ProductCarouselActionOnFirstAppear.nonexistent
                }

                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: requestListingId),
                                                          source: .external, actionOnFirstAppear: actionOnFirstAppear)
            }
        case .promoted:
            tabBarCtl.clearAllPresented(nil)
            openPromoteBumpForListingId(listingId: requestListingId,
                                        bumpUpProductData: bumpUpProductData,
                                        typePage: typePage)
        case .edit(let listing):
            openEditForListing(listing: listing,
                               bumpUpProductData: bumpUpProductData,
                               maxCountdown: maxCountdown)
        case .sellEdit(let listing):
            openEditForListing(listing: listing,
                               bumpUpProductData: bumpUpProductData,
                               maxCountdown: maxCountdown)
        }
    }
}

extension AppCoordinator: PromoteBumpCoordinatorDelegate {
    func openSellFaster(listingId: String,
                        bumpUpProductData: BumpUpProductData,
                        typePage: EventParameterTypePage?) {
        tabBarCtl.clearAllPresented(nil)
        openUserProfile() { [weak self] in

            let triggerBumpOnAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(bumpUpProductData: bumpUpProductData,
                                                                                       bumpUpType: .priced,
                                                                                       triggerBumpUpSource: .promoted,
                                                                                       typePage: typePage)

            self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: listingId),
                                                      source: .promoteBump,
                                                      actionOnFirstAppear: triggerBumpOnAppear)
            self?.keyValueStorage[.lastShownPromoteBumpDate] = Date()
            
        }
    }
}


extension AppCoordinator: ProfileCoordinatorSearchAlertsDelegate {
    func profileCoordinatorSearchAlertsOpenSearch() {
        openTab(.home) { [weak self] in
            self?.mainTabBarCoordinator.readyToSearch()
        }
    }
}


// MARK: - Tab helper

fileprivate extension Tab {
    var logInRequired: Bool {
        switch self {
        case .home, .sell, .community:
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
        case .community:
            return .community
        }
    }
}
