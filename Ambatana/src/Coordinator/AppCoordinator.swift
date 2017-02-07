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
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager

    let tabBarCtl: TabBarController
    fileprivate let selectedTab: Variable<Tab>

    fileprivate let mainTabBarCoordinator: MainTabCoordinator
    fileprivate let notificationsTabBarCoordinator: NotificationsTabCoordinator
    fileprivate let chatsTabBarCoordinator: ChatsTabCoordinator
    fileprivate let profileTabBarCoordinator: ProfileTabCoordinator
    fileprivate let tabCoordinators: [TabCoordinator]

    fileprivate let configManager: ConfigManager
    fileprivate let sessionManager: SessionManager
    fileprivate let keyValueStorage: KeyValueStorage

    fileprivate let pushPermissionsManager: PushPermissionsManager
    fileprivate let ratingManager: RatingManager
    fileprivate let tracker: Tracker
    fileprivate let deepLinksRouter: DeepLinksRouter

    fileprivate let productRepository: ProductRepository
    fileprivate let userRepository: UserRepository
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let oldChatRepository: OldChatRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let commercializerRepository: CommercializerRepository
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
                  bubbleNotificationManager: BubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  pushPermissionsManager: PushPermissionsManager.sharedInstance,
                  ratingManager: RatingManager.sharedInstance,
                  deepLinksRouter: DeepLinksRouter.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  productRepository: Core.productRepository,
                  userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository,
                  oldChatRepository: Core.oldChatRepository,
                  chatRepository: Core.chatRepository,
                  commercializerRepository: Core.commercializerRepository,
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
         productRepository: ProductRepository,
         userRepository: UserRepository,
         myUserRepository: MyUserRepository,
         oldChatRepository: OldChatRepository,
         chatRepository: ChatRepository,
         commercializerRepository: CommercializerRepository,
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

        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.oldChatRepository = oldChatRepository
        self.chatRepository = chatRepository
        self.commercializerRepository = commercializerRepository
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

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        // Cannot open as cannot have a parent view controller
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        // Cannot close
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
        openCoordinator(coordinator: onboardingCoordinator, parent: tabBarCtl, animated: true, completion: nil)
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

    func openSell(_ source: PostingSource) {
        let sellCoordinator = SellCoordinator(source: source)
        sellCoordinator.delegate = self
        openCoordinator(coordinator: sellCoordinator, parent: tabBarCtl, animated: true, completion: nil)
    }

    func openUserRating(_ source: RateUserSource, data: RateUserData) {
        let userRatingCoordinator = UserRatingCoordinator(source: source, data: data)
        userRatingCoordinator.delegate = self
        openCoordinator(coordinator: userRatingCoordinator, parent: tabBarCtl, animated: true, completion: nil)
    }
    
    func openChangeLocation() {
        profileTabBarCoordinator.openEditLocation()
    }

    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        let viewModel = VerifyAccountsViewModel(verificationTypes: types, source: source, completionBlock: completionBlock)
        let viewController = VerifyAccountsViewController(viewModel: viewModel)
        tabBarCtl.present(viewController, animated: true, completion: nil)
    }
    
    func openResetPassword(_ token: String) {
        let changePasswordCoordinator = ChangePasswordCoordinator(token: token)
        changePasswordCoordinator.delegate = self
        openCoordinator(coordinator: changePasswordCoordinator, parent: tabBarCtl, animated: true, completion: nil)
    }
    
    func openNPSSurvey() {
        guard featureFlags.showNPSSurvey else { return }
        delay(3) { [weak self] in
            let vc = NPSViewController(viewModel: NPSViewModel())
            self?.tabBarCtl.present(vc, animated: true, completion: nil)
        }
    }

    func openAppInvite() {
        AppShareViewController.showOnViewControllerIfNeeded(tabBarCtl)
    }

    func canOpenAppInvite() -> Bool {
        return AppShareViewController.canBeShown()
    }
}


// MARK: - CoordinatorDelegate

extension AppCoordinator: CoordinatorDelegate {
    func coordinatorDidClose(_ coordinator: Coordinator) {
        child = nil
    }
}


// MARK: - SellCoordinatorDelegate

extension AppCoordinator: SellCoordinatorDelegate {
    func sellCoordinatorDidCancel(_ coordinator: SellCoordinator) {}

    func sellCoordinator(_ coordinator: SellCoordinator, didFinishWithProduct product: Product) {
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
    func userRatingCoordinatorDidCancel(_ coordinator: UserRatingCoordinator) {}

    func userRatingCoordinatorDidFinish(_ coordinator: UserRatingCoordinator, withRating rating: Int?) {
        if rating == 5 {
            tabBarCtl.showAppRatingViewIfNeeded(.chat)
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
            showAppRatingViewIfNeeded(.productSellComplete)
        } else {
            return false
        }
        return true
    }

    @discardableResult func showAppRatingViewIfNeeded(_ source: EventParameterRatingSource) -> Bool {
        return tabBarCtl.showAppRatingViewIfNeeded(source)
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
        let result: Bool
        let afterLogInSuccessful: () -> ()

        switch tab {
        case .home, .notifications, .chats, .profile:
            afterLogInSuccessful = { [weak self] in self?.openTab(tab, force: true, completion: nil) }
            result = !shouldOpenLogin
        case .sell:
            afterLogInSuccessful = { [weak self] in
                self?.openSell(.tabBar)
            }
            result = false
            if sessionManager.loggedIn {
                openSell(.tabBar)
            }
        }

        if let source = tab.logInSource, shouldOpenLogin {
            openLogin(.fullScreen, source: source, afterLogInSuccessful: afterLogInSuccessful)
        } else {
            switch tab {
            case .home, .notifications, .chats, .profile:
                // tab is changed after returning from this method
                break
            case .sell:
                openSell(.tabBar)
            }
        }
        return result
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
            if let currentLocation = strongSelf.locationManager.currentLocation, currentLocation.isAuto && !strongSelf.featureFlags.locationMatchesCountry {
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
        openLoginIfNeeded(from: from, appearance: .light, style: .fullScreen,
                          preDismissLoginBlock: nil, loggedInAction: loggedInAction, delegate: self)
    }
}


// MARK: - LoginCoordinatorDelegate

extension AppCoordinator: LoginCoordinatorDelegate {}


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
    func openCoordinator(coordinator: Coordinator, parent: UIViewController, animated: Bool,
                                     completion: (() -> Void)?) {
        guard child == nil else { return }
        child = coordinator
        coordinator.open(parent: parent, animated: animated, completion: completion)
    }

    func openTab(_ tab: Tab, force: Bool, completion: (() -> ())?) {
        let shouldOpen = force || shouldOpenTab(tab)
        if shouldOpen {
            tabBarCtl.switchToTab(tab, completion: completion)
        }
    }

    func openLogin(_ style: LoginStyle, source: EventParameterLoginSourceValue, afterLogInSuccessful: @escaping () -> ()) {
        let coordinator = LoginCoordinator(source: source, appearance: .light, style: style,
                                           preDismissLoginBlock: nil, loggedInAction: afterLogInSuccessful)
        coordinator.delegate = self
        openCoordinator(coordinator: coordinator, parent: tabBarCtl, animated: true, completion: nil)
    }

    /**
     Those links will always come from an inactive state of the app. So it means the user clicked a push, a link or a 
     shortcut. 
     As it was a user action we must perform navigation
     */
    func openExternalDeepLink(_ deepLink: DeepLink, initialDeepLink: Bool = false) {
        let event = TrackerEvent.openAppExternal(deepLink.campaign, medium: deepLink.medium, source: deepLink.source)
        tracker.trackEvent(event)

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
            afterDelayClosure = { [weak self] in
                self?.selectedTabCoordinator?.openProduct(ProductDetailData.id(productId: productId), source: .openApp,
                                                          showKeyboardOnFirstAppearIfNeeded: false)
            }
        case let .user(userId):
            if userId == myUserRepository.myUser?.objectId {
                openTab(.profile, force: false, completion: nil)
            } else {
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
                self?.openTab(.home, force: false) { [weak self] in
                    self?.openResetPassword(token)
                }
            }
        case .commercializer:
            break // Handled on CommercializerManager
        case .commercializerReady(let productId, let templateId):
            if initialDeepLink {
                CommercializerManager.sharedInstance.commercializerReadyInitialDeepLink(productId: productId,
                                                                                        templateId: templateId)
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
        case .home, .sell, .product, .user, .conversations, .search, .resetPassword, .commercializer,
             .commercializerReady, .userRatings, .userRating, .passiveBuyers:
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
