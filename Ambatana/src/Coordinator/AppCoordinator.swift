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
    fileprivate let oldChatRepository: OldChatRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let userRatingRepository: UserRatingRepository
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let locationManager: LocationManager

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
                  oldChatRepository: Core.oldChatRepository,
                  chatRepository: Core.chatRepository,
                  userRatingRepository: Core.userRatingRepository,
                  locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance)
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
         oldChatRepository: OldChatRepository,
         chatRepository: ChatRepository,
         userRatingRepository: UserRatingRepository,
         locationManager: LocationManager,
         featureFlags: FeatureFlaggeable) {

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
        self.oldChatRepository = oldChatRepository
        self.chatRepository = chatRepository
        self.userRatingRepository = userRatingRepository
        
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

    func openSell(_ source: PostingSource) {
        let sellCoordinator = SellCoordinator(source: source)
        sellCoordinator.delegate = self
        openChild(coordinator: sellCoordinator, parent: tabBarCtl, animated: true, forceCloseChild: true, completion: nil)
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        guard ratingManager.shouldShowRating else { return }
        tabBarCtl.showAppRatingView(source)
    }

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
}


// MARK: - SellCoordinatorDelegate

extension AppCoordinator: SellCoordinatorDelegate {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator) {}

    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithListing listing: Listing) {
        refreshSelectedProductsRefreshable()

        openAfterSellDialogIfNeeded()
    }
}


// MARK: - OnboardingCoordinatorDelegate

extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingCoordinator(_ coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?) {
        delegate?.appNavigatorDidOpenApp()
        if let source = source, posting {
            openSell(source)
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
    func refreshSelectedProductsRefreshable() {
        guard let selectedVC = tabBarCtl.selectedViewController else { return }
        guard let refreshable = topViewControllerInController(selectedVC) as? ProductsRefreshable else { return }
        refreshable.productsRefresh()
    }

    @discardableResult func openAfterSellDialogIfNeeded() -> Bool {
        if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.sell) {
            pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .sell, completion: nil)
        } else if ratingManager.shouldShowRating {
            openAppRating(.productSellComplete)
        } else {
            return false
        }
        return true
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
        case .home, .notifications, .chats, .profile:
            afterLogInSuccessful = { [weak self] in self?.openTab(tab, force: true, completion: nil) }
        case .sell:
            afterLogInSuccessful = { [weak self] in self?.openSell(.tabBar) }
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
                openSell(.tabBar)
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

    func openLogin(_ style: LoginStyle, source: EventParameterLoginSourceValue, afterLogInSuccessful: @escaping () -> (), cancelAction: (() -> Void)?) {
        let coordinator = LoginCoordinator(source: source, style: style, loggedInAction: afterLogInSuccessful, cancelAction: cancelAction)
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
                self?.openSell(.deepLink)
            }
        case let .product(productId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: productId), source: .openApp, actionOnFirstAppear: .nonexistent)
            }
        case let .productShare(productId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: productId), source: .openApp, actionOnFirstAppear: .showShareSheet)
            }
        case let .productMarkAsSold(productId):
            tabBarCtl.clearAllPresented(nil)
            afterDelayClosure = { [weak self] in
                self?.openTab(.profile, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openListing(ListingDetailData.id(listingId: productId), source: .openApp, actionOnFirstAppear: .triggerMarkAsSold)
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
        case let .conversation(data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(data: data), source:.external)
                }
            }
        case .message(_, let data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(data: data), source: .external)
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
        case let .passiveBuyers(productId):
            afterDelayClosure = { [weak self] in
                self?.openTab(.notifications, completion: {
                    self?.openPassiveBuyers(productId)
                })
            }
        case .notificationCenter:
            openTab(.notifications, force: false, completion: nil)
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
        case .home, .sell, .product, .productShare, .productMarkAsSold, .user, .conversations, .search, .resetPassword, .userRatings, .userRating,
             .passiveBuyers, .notificationCenter:
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
        guard featureFlags.userReviews else { return }
        guard let navCtl = selectedNavigationController else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        let viewModel = UserRatingListViewModel(userId: myUserId, tabNavigator: profileTabBarCoordinator)

        let hidesBottomBarWhenPushed = navCtl.viewControllers.count == 1
        let viewController = UserRatingListViewController(viewModel: viewModel,
                                                          hidesBottomBarWhenPushed: hidesBottomBarWhenPushed)
        navCtl.pushViewController(viewController, animated: true)
    }

    func openUserRatingForUserFromRating(_ ratingId: String) {
        guard featureFlags.userReviews else { return }
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
                case .internalError, .notFound, .unauthorized, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                    message = LGLocalizedString.commonUserReviewNotAvailable
                }
                navCtl.dismissLoadingMessageAlert {
                    navCtl.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func showInappChatNotification(_ data: ConversationData, message: String) {
        guard sessionManager.loggedIn else { return }
        //Avoid showing notification if user is already in that conversation.
        guard let selectedTabCoordinator = selectedTabCoordinator, !selectedTabCoordinator.isShowingConversation(data) else { return }

        let conversationId: String
        switch data {
        case let .conversation(id):
            conversationId = id
        default:
            return
        }

        tracker.trackEvent(TrackerEvent.inappChatNotificationStart())
        if featureFlags.websocketChat {
            chatRepository.showConversation(conversationId) { [weak self] result in
                guard let conversation = result.value else { return }
                let action = UIAction(interface: .text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                    self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                    self?.openTab(.chats, force: false) { [weak self] in
                        self?.selectedTabCoordinator?.openChat(.conversation(conversation: conversation), source: .inAppNotification )
                    }
                })
                let data = BubbleNotificationData(tagGroup: conversationId,
                                                  text: message,
                                                  action: action,
                                                  iconURL: conversation.interlocutor?.avatar?.fileURL,
                                                  iconImage: UIImage(named: "user_placeholder"))
                self?.showBubble(with: data, duration: Constants.bubbleChatDuration)
            }
        } else {
            // Old chat cannot retrieve chat because it would mark messages as read.
            let action = UIAction(interface: .text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openChat(.dataIds(data: data), source: .inAppNotification)
                }
            })
            let data = BubbleNotificationData(tagGroup: conversationId,
                                              text: message,
                                              action: action)
            showBubble(with: data, duration: Constants.bubbleChatDuration)
        }
    }

    func openPassiveBuyers(_ productId: String) {
        guard let notificationsTabCoordinator = selectedTabCoordinator as? NotificationsTabCoordinator else { return }
        notificationsTabCoordinator.openPassiveBuyers(productId, actionCompletedBlock: nil)
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
