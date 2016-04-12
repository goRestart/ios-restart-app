//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result
import UIKit
import RxSwift


protocol ScrollableToTop {
    func scrollToTop()
}

final class TabBarController: UITabBarController, UITabBarControllerDelegate, UINavigationControllerDelegate {

    // Constants & enums
    private static let tooltipVerticalSpacingAnimBottom: CGFloat = 5
    private static let tooltipVerticalSpacingAnimTop: CGFloat = 25

    // UI
    var floatingSellButton: FloatingButton!
    var floatingSellButtonMarginConstraint: NSLayoutConstraint! //Will be initialized on init
    var sellButton: UIButton!
    var chatsTabBarItem: UITabBarItem? {
        guard let vcs = viewControllers where 0..<vcs.count ~= Tab.Chats.rawValue else { return nil }
        return vcs[Tab.Chats.rawValue].tabBarItem
    }

    private let viewModel: TabBarViewModel

    // Rx
    private let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: TabBarViewModel())
    }

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        setupAdmin()
        setupControllers()
        setupSellButtons()

        updateChatsBadge()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.askUserToUpdateLocation),
            name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)

        setupDeepLinkingRx()
        setupCommercializerRx()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.unreadMessagesDidChange(_:)),
            name: PushManager.Notification.UnreadMessagesDidChange.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.logout(_:)),
            name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.kickedOut(_:)),
            name: SessionManager.Notification.KickedOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.applicationWillEnterForeground(_:)),
            name: UIApplicationWillEnterForegroundNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        // Move the sell button
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton.frame = CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth,
            height: tabBar.frame.height)
    }
    
    
    // MARK: - Public / Internal methods
    
    func switchToTab(tab: Tab) {
        switchToTab(tab, checkIfShouldSwitch: true)
    }
    
    /**
    Pops the current navigation controller to root and switches to the given tab.

    - parameter The: tab to go to.
    */
    private func switchToTab(tab: Tab, checkIfShouldSwitch: Bool) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }
        guard let viewControllers = viewControllers else { return }
        guard tab.rawValue < viewControllers.count else { return }
        guard let vc = (viewControllers as NSArray).objectAtIndex(tab.rawValue) as? UIViewController else { return }
        guard let delegate = delegate else { return }
        if checkIfShouldSwitch {
            let shouldSelectVC = delegate.tabBarController?(self, shouldSelectViewController: vc) ?? true
            guard shouldSelectVC else { return }
        }
        
        // Change the tab
        selectedIndex = tab.rawValue
        
        // Pop the navigation back to root
        navBarCtl.popToRootViewControllerAnimated(false)
        
        // Notify the delegate, as programmatically change doesn't do it
        delegate.tabBarController?(self, didSelectViewController: vc)
    }

    /**
    Shows the app rating if needed.

    - returns: Whether app rating has been shown or not
    */
    func showAppRatingViewIfNeeded() -> Bool {
        // If never shown before, show app rating view
        if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
            if let nav = selectedViewController as? UINavigationController, let ratingView = AppRatingView.ratingView() {
                let screenFrame = nav.view.frame
                UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
                ratingView.setupWithFrame(screenFrame, contactBlock: { (vc) -> Void in
                    nav.pushViewController(vc, animated: true)
                })
                self.view.addSubview(ratingView)
                return true
            }
        }
        return false
    }

    /**
    Shows/hides the sell floating button

    - parameter hidden: If should be hidden
    - parameter animated: If transition should be animated
    */
    func setSellFloatingButtonHidden(hidden: Bool, animated: Bool) {
        self.floatingSellButton.layer.removeAllAnimations()

        let alpha: CGFloat = hidden ? 0 : 1
        if animated {

            if !hidden {
                floatingSellButton.hidden = false
            }
            UIView.animateWithDuration(0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                }, completion: { [weak self] (completed) -> Void in
                    if completed {
                        self?.floatingSellButton.hidden = hidden
                    }
                })
        } else {
            floatingSellButton.hidden = hidden
        }
    }

    /**
    Overriding this method because we cannot stick the floatingsellButton to the tabbar. Each time we push a view
    controller that has 'hidesBottomBarWhenPushed = true' tabBar is removed from view hierarchy so the constraint will
    dissapear. Also when the tabBar is set again, is added into a different layer so the constraint cannot be set again.
    */
    override func setTabBarHidden(hidden:Bool, animated:Bool, completion: (Bool -> Void)? = nil) {

        let floatingOffset : CGFloat = (hidden ? -15 : -(tabBar.frame.height + 15))
        floatingSellButtonMarginConstraint.constant = floatingOffset
        super.setTabBarHidden(hidden, animated: animated, completion: completion)

    }


    // MARK: - UINavigationControllerDelegate

    func navigationController(navigationController: UINavigationController,
        willShowViewController viewController: UIViewController, animated: Bool) {
            updateFloatingButtonFor(navigationController, presenting: viewController, animate: false)
    }

    func navigationController(navigationController: UINavigationController,
        didShowViewController viewController: UIViewController, animated: Bool) {
            updateFloatingButtonFor(navigationController, presenting: viewController, animate: true)
    }

    private func updateFloatingButtonFor(navigationController: UINavigationController,
        presenting viewController: UIViewController, animate: Bool) {
            guard let viewControllers = viewControllers else { return }
            guard let rootViewCtrl = navigationController.viewControllers.first else { return }

            let vcIdx = (viewControllers as NSArray).indexOfObject(navigationController)
            if let tab = Tab(rawValue: vcIdx) {
                switch tab {
                case .Home, .Categories, .Sell, .Profile:
                    //In case of those 4 sections, show if ctrl is root, or if its the MainProductsViewController
                    let showBtn = (viewController == rootViewCtrl) || (viewController is MainProductsViewController)
                    setSellFloatingButtonHidden(!showBtn, animated: animate)
                case .Chats:
                    setSellFloatingButtonHidden(true, animated: false)
                }
            }
    }

    // MARK: - UITabBarControllerDelegate

    func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool {
            
            guard let viewControllers = viewControllers else { return false }
            let vcIdx = (viewControllers as NSArray).indexOfObject(viewController)
            guard let tab = Tab(rawValue: vcIdx) else { return false }
            
            var isLogInRequired = false
            var loginSource: EventParameterLoginSourceValue?

            if selectedViewController == viewController {
                if let navVC = viewController as? UINavigationController,
                    let topVC = navVC.topViewController as? ScrollableToTop {
                        topVC.scrollToTop()
                }
            }

            switch tab {
            case .Home, .Categories:
                break
            case .Sell:
                // Do not allow selecting Sell (as we've a sell button over sell button tab)
                return false
            case .Chats:
                loginSource = .Chats
                isLogInRequired = !Core.sessionManager.loggedIn
            case .Profile:
                loginSource = .Profile
                isLogInRequired = !Core.sessionManager.loggedIn
            }
            // If logged present the selected VC, otherwise present the login VC (and if successful the selected  VC)
            if let actualLoginSource = loginSource where isLogInRequired {
                ifLoggedInThen(actualLoginSource, loggedInAction: { [weak self] in
                    self?.switchToTab(tab, checkIfShouldSwitch: false)
                },
                elsePresentSignUpWithSuccessAction: { [weak self] in
                    self?.switchToTab(tab)
                })
            }
            
            return !isLogInRequired
    }


    // MARK: - Private methods
    // MARK: > Setup

    private func setupControllers() {
        // Generate the view controllers
        var vcs: [UIViewController] = []
        for tab in Tab.all {
            vcs.append(controllerForTab(tab))
        }

        // UITabBarController setup
        viewControllers = vcs
        delegate = self
    }

    private func controllerForTab(tab: Tab) -> UIViewController {
        let vc = viewModel.viewControllerForTab(tab)
        let navCtl = UINavigationController(rootViewController: vc ?? UIViewController())
        navCtl.delegate = self


        let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)

        // Customize the selected appereance
        if let imageItem = tabBarItem.selectedImage {
            tabBarItem.image = imageItem.imageWithColor(StyleHelper.tabBarIconUnselectedColor)
                .imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        } else {
            tabBarItem.image = UIImage()
        }

        tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)

        navCtl.tabBarItem = tabBarItem
        return navCtl
    }

    private func setupSellButtons() {
        // Add the sell button as a custom one
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton = UIButton(frame: CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth,
            height: tabBar.frame.height))
        sellButton.addTarget(self, action: #selector(TabBarController.sellButtonPressed),
                             forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: Tab.Sell.tabIconImageName), forState: UIControlState.Normal)
        tabBar.addSubview(sellButton)

        // Add the floating sell button
        floatingSellButton = FloatingButton.floatingButtonWithTitle(LGLocalizedString.tabBarToolTip,
                                                                    icon: UIImage(named: "ic_sell_white"))
        floatingSellButton.addTarget(self, action: #selector(TabBarController.sellButtonPressed),
                                     forControlEvents: UIControlEvents.TouchUpInside)
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)

        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .CenterX,
                                                       relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        floatingSellButtonMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom,
                                                                relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1,
                                                                constant: -(tabBar.frame.height + 15)) // 15 above tabBar
        
        view.addConstraints([sellCenterXConstraint,floatingSellButtonMarginConstraint])
    }

    // MARK: > Action

    dynamic func sellButtonPressed() {
        openSell()
    }
    
    // MARK: > UI
    
    private func openSell() {
        SellProductControllerFactory.presentSellProductOn(viewController: self, delegate: self)
    }

    private func refreshProfileIfShowing() {
        // TODO: THIS IS DIRTY AND COUPLED! REFACTOR!
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }
        guard let rootViewCtrl = navBarCtl.topViewController, let userViewCtrl = rootViewCtrl
            as? UserViewController where userViewCtrl.isViewLoaded() else { return }

        userViewCtrl.refreshSellingProductsList()
    }

    // MARK: > NSNotification

    dynamic private func logout(notification: NSNotification) {

        if let chatsTab = chatsTabBarItem {
            chatsTab.badgeValue = nil
        }

        // Leave navCtl in its initial state, pop to root
        selectedViewController?.navigationController?.popToRootViewControllerAnimated(false)

        // Switch to home tab
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.switchToTab(.Home)
        })
    }

    dynamic private func kickedOut(notification: NSNotification) {
        showAutoFadingOutMessageAlert(LGLocalizedString.toastErrorInternal)
    }

    dynamic private func applicationWillEnterForeground(notification: NSNotification) {
        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    dynamic private func askUserToUpdateLocation() {

        //Avoid showing the alert inside details (such as settings)
        guard let selectedNavC = selectedViewController as? UINavigationController,
            selectedViewController = selectedNavC.topViewController where selectedViewController.isRootViewController()
            else { return }

        let firstAlert = UIAlertController(title: nil, message: LGLocalizedString.changeLocationAskUpdateLocationMessage,
            preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: LGLocalizedString.commonOk, style: UIAlertActionStyle.Default) { _ in
            Core.locationManager.setAutomaticLocation(nil)
        }
        let noAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel) { [weak self] _ in
            let secondAlert = UIAlertController(title: nil,
                message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil)
            let updateAction = UIAlertAction(title: LGLocalizedString.changeLocationConfirmUpdateButton,
                style: .Default) { _ in
                    Core.locationManager.setAutomaticLocation(nil)
            }
            secondAlert.addAction(cancelAction)
            secondAlert.addAction(updateAction)
            
            self?.presentViewController(secondAlert, animated: true, completion: nil)
        }
        firstAlert.addAction(yesAction)
        firstAlert.addAction(noAction)
        
        presentViewController(firstAlert, animated: true, completion: nil)
        
        // We should ask only one time
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)
    }
}


// MARK: - TabBarViewModelDelegate

extension TabBarController: TabBarViewModelDelegate {
    func vmSwitchToTab(tab: Tab) {
        switchToTab(tab)
    }

    func vmShowProduct(productViewModel viewModel: ProductViewModel) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }

        let vc = ProductViewController(viewModel: viewModel)
        navBarCtl.pushViewController(vc, animated: true)
    }

    func vmShowUser(userViewModel viewModel: UserViewModel) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }

        let vc = UserViewController(viewModel: viewModel)
        navBarCtl.pushViewController(vc, animated: true)
    }

    func vmShowChat(chatViewModel viewModel: ChatViewModel) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }

        let vc = ChatViewController(viewModel: viewModel)
        navBarCtl.pushViewController(vc, animated: true)
    }

    func vmShowResetPassword(changePasswordViewModel viewModel: ChangePasswordViewModel) {
        let vc = ChangePasswordViewController(viewModel: viewModel)
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }

    func vmShowMainProducts(mainProductsViewModel viewModel: MainProductsViewModel) {
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }

        let vc = MainProductsViewController(viewModel: viewModel)
        navBarCtl.pushViewController(vc, animated: true)
    }
}


// MARK: - SellProductViewControllerDelegate

extension TabBarController: SellProductViewControllerDelegate {
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool,
        withPromoteProductViewModel promoteProductVM: PromoteProductViewModel?) {
            guard successfully else { return }
            refreshProfileIfShowing()
            if let promoteProductVM = promoteProductVM {
                let promoteProductVC = PromoteProductViewController(viewModel: promoteProductVM)
                promoteProductVC.delegate = self
                let event = TrackerEvent.commercializerStart(promoteProductVM.productId, typePage: .Sell)
                TrackerProxy.sharedInstance.trackEvent(event)
                presentViewController(promoteProductVC, animated: true, completion: nil)
            } else if PushPermissionsManager.sharedInstance
                .shouldShowPushPermissionsAlertFromViewController(.Sell) {
                    PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: .Sell, completion: nil)
            } else if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
                showAppRatingViewIfNeeded()
            }
    }

    func sellProductViewController(sellVC: SellProductViewController?, didFinishPostingProduct
        postedViewModel: ProductPostedViewModel) {

            let productPostedVC = ProductPostedViewController(viewModel: postedViewModel)
            productPostedVC.delegate = self
            presentViewController(productPostedVC, animated: true, completion: nil)
    }

    func sellProductViewController(sellVC: SellProductViewController?,
        didEditProduct editVC: EditSellProductViewController?) {
            guard let editVC = editVC else { return }
            let navC = UINavigationController(rootViewController: editVC)
            presentViewController(navC, animated: true, completion: nil)
    }

    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?) {
        openSell()
    }
}


// MARK: - PromoteProductViewControllerDelegate

extension TabBarController: PromoteProductViewControllerDelegate {
    func promoteProductViewControllerDidFinishFromSource(promotionSource: PromotionSource) {
        postActions(promotionSource)
    }
    
    func promoteProductViewControllerDidCancelFromSource(promotionSource: PromotionSource) {
        postActions(promotionSource)
    }
    
    private func postActions(source: PromotionSource) {
        if source.hasPostPromotionActions {
            if PushPermissionsManager.sharedInstance
                .shouldShowPushPermissionsAlertFromViewController(.Sell) {
                PushPermissionsManager.sharedInstance.showPrePermissionsViewFrom(self, type: .Sell, completion: nil)
            } else if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
                showAppRatingViewIfNeeded()
            }
        }
    }
}


// MARK: Chat & Conversation related

extension TabBarController {

    dynamic private func unreadMessagesDidChange(notification: NSNotification) {
        updateChatsBadge()
    }

    private func updateChatsBadge() {
        guard let chatsTab = chatsTabBarItem else { return }
        let badgeNumber = PushManager.sharedInstance.unreadMessagesCount
        chatsTab.badgeValue = badgeNumber > 0 ? "\(badgeNumber)" : nil
    }

    private func isShowingConversationForConversationData(data: ConversationData) -> Bool {
        guard let currentVC = selectedViewController as? UINavigationController,
            let topVC = currentVC.topViewController as? ChatViewController else { return false }

        return topVC.isMatchingConversationData(data)
    }
}


// MARK: - Deep Links

extension TabBarController {

    func consumeDeepLinkIfAvailable() {
        guard let deepLink = DeepLinksRouter.sharedInstance.consumeInitialDeepLink() else { return }

        openDeepLink(deepLink, initialDeepLink: true)
    }

    private func setupDeepLinkingRx() {
        DeepLinksRouter.sharedInstance.deepLinks.asObservable().filter{ _ in
            //We only want links that open from outside the app
            UIApplication.sharedApplication().applicationState != .Active
        }.subscribeNext { [weak self] deepLink in
            self?.openDeepLink(deepLink, initialDeepLink: false)
        }.addDisposableTo(disposeBag)
    }

    private func openDeepLink(deepLink: DeepLink, initialDeepLink: Bool) {
        var afterDelayClosure: (() -> Void)?
        switch deepLink {
        case .Home:
            switchToTab(.Home)
        case .Sell:
            openSell()
        case .Product(let productId):
            afterDelayClosure =  { [weak self] in
                self?.viewModel.openProductWithId(productId)
            }
        case .User(let userId):
            afterDelayClosure =  { [weak self] in
                self?.viewModel.openUserWithId(userId)
            }
        case .Conversations:
            switchToTab(.Chats)
        case .Conversation(let conversationData):
            afterDelayClosure = checkConversationAndGetAfterDelayClosure(conversationData)
        case .Message(_, let conversationData):
            afterDelayClosure = checkConversationAndGetAfterDelayClosure(conversationData)
        case .Search(let query, let categories):
            switchToTab(.Home)
            afterDelayClosure = { [weak self] in
                self?.viewModel.openSearch(query, categoriesString: categories)
            }
        case .ResetPassword(let token):
            switchToTab(.Home)
            afterDelayClosure = { [weak self] in
                self?.viewModel.openResetPassword(token)
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
            dispatch_after(delayTime, dispatch_get_main_queue(), afterDelayClosure)
        }
    }

    private func checkConversationAndGetAfterDelayClosure(data: ConversationData) -> (() -> Void)? {
        guard !isShowingConversationForConversationData(data) else { return nil }

        switchToTab(.Chats)
        return { [weak self] in
            switch data {
            case .Conversation(let conversationId):
                self?.viewModel.openChatWithConversationId(conversationId)
            case let .ProductBuyer(productId, buyerId):
                self?.viewModel.openChatWithProductId(productId, buyerId: buyerId)
            }
        }
    }
}


// MARK: - Commercializer

extension TabBarController {

    private func setupCommercializerRx() {
        CommercializerManager.sharedInstance.commercializers.asObservable().subscribeNext { [weak self] data in
            self?.openCommercializer(data)
        }.addDisposableTo(disposeBag)
    }

    private func openCommercializer(data: CommercializerData) {
        let vc: UIViewController
        if data.shouldShowPreview {
            let viewModel = CommercialPreviewViewModel(productId: data.productId, commercializer: data.commercializer)
            vc = CommercialPreviewViewController(viewModel: viewModel)
        } else {
            guard let viewModel = CommercialDisplayViewModel(commercializers: [data.commercializer],
                                                             productId: data.productId,
                                                             source: .External,
                                                             isMyVideo: data.isMyVideo) else { return }
            vc = CommercialDisplayViewController(viewModel: viewModel)
        }

        if let presentedVC = presentedViewController {
            presentedVC.dismissViewControllerAnimated(false, completion: nil)
        }

        presentViewController(vc, animated: true, completion: nil)
    }
}


// MARK: - Admin

extension TabBarController: UIGestureRecognizerDelegate {

    private func setupAdmin() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(TabBarController.longPressProfileItem(_:)))
        longPress.delegate = self
        self.tabBar.addGestureRecognizer(longPress)
    }

    func longPressProfileItem(recognizer: UILongPressGestureRecognizer) {
        guard AdminViewController.canOpenAdminPanel() else { return }
        let admin = AdminViewController()
        let nav = UINavigationController(rootViewController: admin)
        presentViewController(nav, animated: true, completion: nil)
    }

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return selectedIndex == Tab.Categories.rawValue // Categories tab because it won't show the login modal view
    }
}
