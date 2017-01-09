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

final class AppCoordinator: BaseCoordinator {
    var child: Coordinator?

    let tabBarCtl: TabBarController
    private let selectedTab: Variable<Tab>

    private let mainTabBarCoordinator: MainTabCoordinator
    private let secondTabBarCoordinator: TabCoordinator
    private let chatsTabBarCoordinator: ChatsTabCoordinator
    private let profileTabBarCoordinator: ProfileTabCoordinator
    private let categoriesTabBarCoordinator: CategoriesTabCoordinator
    private let notificationsTabBarCoordinator: NotificationsTabCoordinator
    private let tabCoordinators: [TabCoordinator]

    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    private let keyValueStorage: KeyValueStorage

    private let pushPermissionsManager: PushPermissionsManager
    private let ratingManager: RatingManager
    private let bubbleNotificationManager: BubbleNotificationManager
    private let tracker: Tracker
    private let deepLinksRouter: DeepLinksRouter

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let oldChatRepository: OldChatRepository
    private let chatRepository: ChatRepository
    private let commercializerRepository: CommercializerRepository
    private let userRatingRepository: UserRatingRepository
    private let featureFlags: FeatureFlaggeable
    private let locationManager: LocationManager

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
        let tracker = TrackerProxy.sharedInstance

        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let myUserRepository = Core.myUserRepository
        let oldChatRepository = Core.oldChatRepository
        let chatRepository = Core.chatRepository
        let commercializerRepository = Core.commercializerRepository
        let userRatingRepository = Core.userRatingRepository
        let featureFlags = FeatureFlags.sharedInstance
        let locationManager = Core.locationManager

        self.init(tabBarController: tabBarController, configManager: configManager, sessionManager: sessionManager,
                  keyValueStorage: keyValueStorage, pushPermissionsManager: pushPermissionsManager,
                  ratingManager: ratingManager, deepLinksRouter: deepLinksRouter, bubbleManager: bubbleManager,
                  tracker: tracker, productRepository: productRepository, userRepository: userRepository,
                  myUserRepository: myUserRepository, oldChatRepository: oldChatRepository, chatRepository: chatRepository,
                  commercializerRepository: commercializerRepository, userRatingRepository: userRatingRepository,
                  locationManager: locationManager, featureFlags: featureFlags)
        tabBarViewModel.navigator = self
    }

    init(tabBarController: TabBarController, configManager: ConfigManager, sessionManager: SessionManager,
         keyValueStorage: KeyValueStorage, pushPermissionsManager: PushPermissionsManager, ratingManager: RatingManager,
         deepLinksRouter: DeepLinksRouter, bubbleManager: BubbleNotificationManager, tracker: Tracker,
         productRepository: ProductRepository, userRepository: UserRepository, myUserRepository: MyUserRepository,
         oldChatRepository: OldChatRepository, chatRepository: ChatRepository, commercializerRepository: CommercializerRepository,
         userRatingRepository: UserRatingRepository, locationManager: LocationManager, featureFlags: FeatureFlaggeable) {

        self.tabBarCtl = tabBarController
        self.selectedTab = Variable<Tab>(.Home)
        
        self.mainTabBarCoordinator = MainTabCoordinator()
        self.categoriesTabBarCoordinator = CategoriesTabCoordinator()
        self.notificationsTabBarCoordinator = NotificationsTabCoordinator()
        self.secondTabBarCoordinator = featureFlags.notificationsSection ? notificationsTabBarCoordinator :
                                                                           categoriesTabBarCoordinator
        self.chatsTabBarCoordinator = ChatsTabCoordinator()
        self.profileTabBarCoordinator = ProfileTabCoordinator()
        self.tabCoordinators = [mainTabBarCoordinator, secondTabBarCoordinator, chatsTabBarCoordinator,
                                profileTabBarCoordinator]

        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.pushPermissionsManager = pushPermissionsManager
        self.ratingManager = ratingManager
        self.bubbleNotificationManager = bubbleManager
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

        super.init(viewController: tabBarCtl, bubbleNotificationManager: bubbleNotificationManager)
        setupTabBarController()
        setupTabCoordinators()
        setupDeepLinkingRx()
        setupCoreEventsRx()
        setupLeanplumPopUp()
    }

    func openTab(_ tab: Tab, completion: (() -> ())?) {
        openTab(tab, force: false, completion: completion)
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
            tabBarCtl.showAppRatingView(EventParameterRatingSource.Chat)
        }
    }
}

fileprivate extension AppCoordinator {
    func refreshSelectedProductsRefreshable() {
        guard let selectedVC = tabBarCtl.selectedViewController else { return }
        guard let refreshable = topViewControllerInController(selectedVC) as? ProductsRefreshable else { return }
        refreshable.productsRefresh()
    }

    func openAfterSellDialogIfNeeded() -> Bool {
        if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.sell) {
            pushPermissionsManager.showPrePermissionsViewFrom(tabBarCtl, type: .sell,
                                                                             completion: nil)
        } else if ratingManager.shouldShowRating {
            showAppRatingViewIfNeeded(.ProductSellComplete)
        } else {
            return false
        }
        return true
    }

    func showAppRatingViewIfNeeded(_ source: EventParameterRatingSource) -> Bool {
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
        case .home, .categories, .notifications, .chats, .profile:
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
            case .home, .categories, .notifications, .chats, .profile:
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


    func setupCoreEventsRx() {
        sessionManager.sessionEvents.bindNext { [weak self] event in
            switch event {
            case .Login:
                break
            case let .Logout(kickedOut):
                self?.openTab(.Home) { [weak self] in
                    if kickedOut {
                        self?.tabBarCtl.showAutoFadingOutMessageAlert(LGLocalizedString.toastErrorInternal)
                    }
                }
            }
        }.addDisposableTo(disposeBag)

        locationManager.locationEvents.filter { $0 == .MovedFarFromSavedManualLocation }.take(1).bindNext {
            [weak self] _ in
            self?.askUserToUpdateLocation()
        }.addDisposableTo(disposeBag)
        
        locationManager.locationEvents.filter { $0 == .LocationUpdate }.take(1).bindNext {
            [weak self] _ in
            guard let strongSelf = self else { return }
            if let currentLocation = strongSelf.locationManager.currentLocation, currentLocation.isAuto && strongSelf.featureFlags.locationNoMatchesCountry {
                strongSelf.askUserToUpdateLocationManually()
            }
            }.addDisposableTo(disposeBag)
       }

    func askUserToUpdateLocation() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }

        let yesAction = UIAction(interface: .StyledText(LGLocalizedString.commonOk, .default), action: { [weak self] in
            self?.locationManager.setAutomaticLocation(nil)
            })
        navCtl.showAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: LGLocalizedString.commonCancel, actions: [yesAction])
    }
    
    func askUserToUpdateLocationManually() {
        guard let navCtl = selectedNavigationController else { return }
        guard navCtl.isAtRootViewController else { return }
        
        let yesAction = UIAction(interface: .styledText(LGLocalizedString.commonOk, .default), action: { [weak self] in
            self?.ifLoggedInAction(.Profile) { [weak self] in
                self?.openTab(.profile) { [weak self] in
                    self?.openChangeLocation()
                }
            }
            })
        navCtl.showAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                         cancelLabel: LGLocalizedString.commonCancel, actions: [yesAction])
    }
    
    func ifLoggedInAction(_ tab: EventParameterLoginSourceValue, action: () -> ()) {
        viewController?.ifLoggedInThen(tab, loginStyle: .fullScreen, loggedInAction: action, elsePresentSignUpWithSuccessAction: action)
    }
}

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
        let viewModel = SignUpViewModel(appearance: .Light, source: source)
        switch style {
        case .fullScreen:
            let vc = MainSignUpViewController(viewModel: viewModel)
            vc.afterLoginAction = afterLogInSuccessful
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.view.backgroundColor = UIColor.white
            tabBarCtl.present(navCtl, animated: true, completion: nil)
        case .popup(let message):
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
                    self?.chatsTabBarCoordinator.openChat(.dataIds(data: data))
                }
            }
        case .message(_, let data):
            afterDelayClosure = { [weak self] in
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.chatsTabBarCoordinator.openChat(.dataIds(data: data))
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
                    self?.openUserRating(.DeepLink, data: data)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .network:
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
                    self?.openTab(.Chats, force: false) { [weak self] in
                        self?.selectedTabCoordinator?.openChat(.Conversation(conversation: conversation))
                    }
                })
                let data = BubbleNotificationData(tagGroup: conversationId,
                                                  text: message,
                                                  action: action,
                                                  iconURL: conversation.interlocutor?.avatar?.fileURL,
                                                  iconImage: UIImage(named: "user_placeholder"))
                self?.showBubble(with: data, duration: 3)
            }
        } else {
            // Old chat cannot retrieve chat because it would mark messages as read.
            let action = UIAction(interface: .text(LGLocalizedString.appNotificationReply), action: { [weak self] in
                self?.tracker.trackEvent(TrackerEvent.inappChatNotificationComplete())
                self?.openTab(.chats, force: false) { [weak self] in
                    self?.selectedTabCoordinator?.openChat(.dataIds(data: data))
                }
            })
            let data = BubbleNotificationData(tagGroup: conversationId,
                                              text: message,
                                              action: action)
            showBubble(with: data, duration: 3)
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
        case .home, .categories, .sell:
            return false
        case .notifications, .chats, .profile:
            return true
        }
    }
    var logInSource: EventParameterLoginSourceValue? {
        switch self {
        case .home, .categories:
            return nil
        case .notifications:
            return .Notifications
        case .sell:
            return .sell
        case .chats:
            return .Chats
        case .profile:
            return .Profile
        }
    }
    var chatHeadsHidden: Bool {
        switch self {
        case .chats, .sell:
            return true
        case .home, .categories, .notifications, .profile:
            return false
        }
    }
}
