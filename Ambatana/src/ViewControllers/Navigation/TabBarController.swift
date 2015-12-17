//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result
import UIKit

public final class TabBarController: UITabBarController, SellProductViewControllerDelegate,
UITabBarControllerDelegate, UINavigationControllerDelegate {

    // Constants & enums
    private static let tooltipVerticalSpacingAnimBottom: CGFloat = 5
    private static let tooltipVerticalSpacingAnimTop: CGFloat = 25

    /**
    Defines the tabs contained in the TabBarController
    */
    enum Tab: Int {
        case Home = 0, Categories = 1, Sell = 2, Chats = 3, Profile = 4

        var tabIconImageName: String {
            switch self {
            case Home:
                return "tabbar_home"
            case Categories:
                return "tabbar_categories"
            case Sell:
                return "tabbar_sell"
            case Chats:
                return "tabbar_chats"
            case Profile:
                return "tabbar_profile"
            }
        }

        var viewController: UIViewController? {
            switch self {
            case Home:
                return MainProductsViewController()
            case Categories:
                return CategoriesViewController()
            case Sell:
                return nil
            case Chats:
                return ChatListViewController()
            case Profile:
                if let user = MyUserManager.sharedInstance.myUser() {
                    return EditProfileViewController(user: user)
                }
            }
            return nil
        }

        static var all:[Tab]{
            return Array(AnySequence { () -> AnyGenerator<Tab> in
                var i = 0
                return anyGenerator{
                    return Tab(rawValue: i++)
                }
                }
            )
        }
    }

    // Managers
    var productManager: ProductManager
    var userManager: UserManager

    // Deep link
    var deepLink: DeepLink?

    // UI
    var floatingSellButton: FloatingButton!
    var floatingSellButtonMarginConstraint: NSLayoutConstraint! //Will be initialized on init
    var sellButton: UIButton!
    var chatsTabBarItem: UITabBarItem?

    // MARK: - Lifecycle

    public convenience init() {
        let productManager = ProductManager()
        let userManager = UserManager()
        let deepLink: DeepLink? = nil
        self.init(productManager: productManager, userManager: userManager, deepLink: deepLink)
    }

    public required init(productManager: ProductManager, userManager: UserManager, deepLink: DeepLink?) {
        // Managers
        self.productManager = productManager
        self.userManager = userManager

        // Deep link
        self.deepLink = deepLink

        super.init(nibName: nil, bundle: nil)

        // Generate the view controllers
        var vcs: [UIViewController] = []
        for tab in Tab.all {
            vcs.append(controllerForTab(tab))
        }

        // Get the chats tab bar items
        if vcs.count > Tab.Chats.rawValue {
            chatsTabBarItem = vcs[Tab.Chats.rawValue].tabBarItem
        }

        // UITabBarController setup
        viewControllers = vcs
        delegate = self

        // Add the sell button as a custom one
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton = UIButton(frame: CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth,
            height: tabBar.frame.height))
        sellButton.addTarget(self, action: Selector("sellButtonPressed"),
            forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: Tab.Sell.tabIconImageName), forState: UIControlState.Normal)
        //        sellButton.backgroundColor = StyleHelper.tabBarSellIconBgColor
        tabBar.addSubview(sellButton)

        // Add the floating sell button
        floatingSellButton = FloatingButton.floatingButtonWithTitle(LGLocalizedString.tabBarToolTip,
            icon: UIImage(named: "ic_sell_white"))
        floatingSellButton.addTarget(self, action: Selector("sellButtonPressed"),
            forControlEvents: UIControlEvents.TouchUpInside)
        floatingSellButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(floatingSellButton)

        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .CenterX, relatedBy: .Equal,
            toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
        floatingSellButtonMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom,
            relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -(tabBar.frame.height + 15))
        // 15 above tabBar

        view.addConstraints([sellCenterXConstraint,floatingSellButtonMarginConstraint])

        // Initially set the chats tab badge to the app icon badge number
        if let chatsTab = chatsTabBarItem {
            let applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
            chatsTab.badgeValue = applicationIconBadgeNumber > 0 ? "\(applicationIconBadgeNumber)" : nil
        }

        // Update chats badge
        updateChatsBadge()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "askUserToUpdateLocation",
            name: MyUserManager.Notification.didMoveFromManualLocationNotification.rawValue, object: nil)

        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unreadMessagesDidChange:",
            name: PushManager.Notification.UnreadMessagesDidChange.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:",
            name: MyUserManager.Notification.logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"),
            name: UIApplicationWillEnterForegroundNotification, object: nil)

        // TODO: Check if can be moved to viewDidLoad
        consumeDeepLinkIfAvailable()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    public override func viewWillLayoutSubviews() {
        // Move the sell button
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton.frame = CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth,
            height: tabBar.frame.height)
    }

    // MARK: - Public / Internal methods

    /**
    Pops the current navigation controller to root and switches to the given tab.

    - parameter The: tab to go to.
    */
    func switchToTab(tab: Tab) {
        if let navBarCtl = selectedViewController as? UINavigationController {

            let vcIdx = tab.rawValue
            if vcIdx < viewControllers?.count {
                if let selectedVC = (viewControllers! as NSArray).objectAtIndex(tab.rawValue) as? UIViewController,
                    let actualDelegate = delegate {

                        // If it should be selected
                        let shouldSelectVC = actualDelegate.tabBarController?(self,
                            shouldSelectViewController: selectedVC) ?? true
                        if shouldSelectVC {

                            // Change the tab
                            selectedIndex = vcIdx

                            // Pop the navigation back to root
                            navBarCtl.popToRootViewControllerAnimated(false)

                            // Notify the delegate, as programmatically change doesn't do it
                            actualDelegate.tabBarController?(self, didSelectViewController: selectedVC)
                        }
                }
            }
        }
    }

    /**
    ...
    */
    func consumeDeepLinkIfAvailable() {
        guard let deepLink = deepLink else { return }

        // Consume and open it
        self.deepLink = nil
        openDeepLink(deepLink)
    }

    func openShortcut(tab: Tab) {

        // dismiss modal (sell or login) before browsing to shortcut
        self.dismissViewControllerAnimated(false, completion: nil)

        switch (tab) {
        case .Sell:
            openSell()
        case .Home, .Categories, .Chats, .Profile:
            switchToTab(tab)
        }
    }

    /**
    Shows the app rating if needed.
    */
    func showAppRatingViewIfNeeded() {
        // If never shown before, show app rating view
        if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
            if let nav = selectedViewController as? UINavigationController, let ratingView = AppRatingView.ratingView() {
                let screenFrame = nav.view.frame
                UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
                ratingView.setupWithFrame(screenFrame, contactBlock: { (vc) -> Void in
                    nav.pushViewController(vc, animated: true)
                })
                self.view.addSubview(ratingView)
            }
        }
    }

    /**
    Shows/hides the sell floating button

    - parameter hidden: If should be hidden
    - parameter animated: If transition should be animated
    */
    func setSellFloatingButtonHidden(hidden: Bool, animated: Bool) {
        let alpha: CGFloat = hidden ? 0 : 1
        if animated {

            if !hidden {
                floatingSellButton.hidden = hidden
            }

            UIView.animateWithDuration(0.35, animations: { [weak self] () -> Void in
                self?.floatingSellButton.alpha = alpha
                }, completion: { [weak self] (_) -> Void in
                    if hidden {
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
    override func setTabBarHidden(hidden:Bool, animated:Bool) {

        let floatingOffset : CGFloat = (hidden ? -15 : -(tabBar.frame.height + 15))
        floatingSellButtonMarginConstraint.constant = floatingOffset
        super.setTabBarHidden(hidden, animated: animated)

    }

    // MARK: - SellProductViewControllerDelegate

    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool) {
        if successfully {
            switchToProfileOnTab(.ProductImSelling)
            if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
                showAppRatingViewIfNeeded()
            } else {
                PushPermissionsManager.sharedInstance.showPushPermissionsAlertFromViewController(self,
                    prePermissionType: .Sell)
            }
        }
    }

    func sellProductViewController(sellVC: SellProductViewController?, didFinishPostingProduct
        postedViewModel: ProductPostedViewModel) {

            let productPostedVC = ProductPostedViewController(viewModel: postedViewModel)
            productPostedVC.delegate = self
            presentViewController(productPostedVC, animated: true, completion: nil)
    }

    func sellProductViewControllerDidTapPostAgain(sellVC: SellProductViewController?) {
        openSell()
    }

    // MARK: - UINavigationControllerDelegate

    public func navigationController(navigationController: UINavigationController,
        willShowViewController viewController: UIViewController, animated: Bool) {
            var hidden = viewController.hidesBottomBarWhenPushed || tabBar.hidden
            if let baseVC = viewController as? BaseViewController {
                hidden = hidden || baseVC.floatingSellButtonHidden
            }

            let vcIdx = (viewControllers! as NSArray).indexOfObject(navigationController)
            if let tab = Tab(rawValue: vcIdx) {
                switch tab {
                case .Home, .Categories, .Sell, .Profile:
                    setSellFloatingButtonHidden(hidden, animated: false)
                case .Chats:
                    setSellFloatingButtonHidden(true, animated: false)
                }
            }
    }

    public func navigationController(navigationController: UINavigationController,
        didShowViewController viewController: UIViewController, animated: Bool) {
            var hidden = viewController.hidesBottomBarWhenPushed || tabBar.hidden
            if let baseVC = viewController as? BaseViewController {
                hidden = hidden || baseVC.floatingSellButtonHidden
            }

            let vcIdx = (viewControllers! as NSArray).indexOfObject(navigationController)
            if let tab = Tab(rawValue: vcIdx) {
                switch tab {
                case .Home, .Categories, .Sell, .Profile:
                    setSellFloatingButtonHidden(hidden, animated: true)
                case .Chats:
                    setSellFloatingButtonHidden(true, animated: false)
                }
            }
    }

    // MARK: - UITabBarControllerDelegate

    public func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool {

            let vcIdx = (viewControllers! as NSArray).indexOfObject(viewController)
            if let tab = Tab(rawValue: vcIdx) {

                var isLogInRequired = false
                var loginSource: EventParameterLoginSourceValue?

                if tab == .Sell {
                    // Do not allow selecting Sell
                    return false
                } else if tab == .Chats {
                    // Chats require login
                    loginSource = .Chats
                    isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
                } else if tab == .Profile {
                    // Profile require login
                    loginSource = .Profile
                    isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
                }

                if let user = MyUserManager.sharedInstance.myUser() {
                    // Profile needs a user update
                    if let navVC = viewController as? UINavigationController, let profileVC = navVC.topViewController
                        as? EditProfileViewController {
                            profileVC.user = user
                    } else if let profileVC = viewController as? EditProfileViewController {
                        profileVC.user = user
                    }
                }

                // If login is required
                if isLogInRequired {

                    // If logged present the selected VC, otherwise present the login VC (and if successful the selected  VC)
                    if let actualLoginSource = loginSource {
                        ifLoggedInThen(actualLoginSource, loggedInAction: { [weak self] in
                            self?.switchToTab(tab)
                            },
                            elsePresentSignUpWithSuccessAction: { [weak self] in
                                // FIXME: UX Patch: https://ambatana.atlassian.net/browse/ABIOS-503
                                if tab == .Profile {
                                    self?.switchToTab(.Home)
                                } else {
                                    self?.switchToTab(tab)
                                }
                            })
                    }
                }

                return !isLogInRequired
            }

            return true
    }

    public func tabBarController(tabBarController: UITabBarController,
        didSelectViewController viewController: UIViewController) {

            // If we have a user
            if let user = MyUserManager.sharedInstance.myUser() {

                // And if it's my profile, then update the user
                if let navVC = viewController as? UINavigationController, let profileVC = navVC.topViewController
                    as? EditProfileViewController {
                        profileVC.user = user
                } else if let profileVC = viewController as? EditProfileViewController {
                    profileVC.user = user
                }
            }
    }

    // MARK: - Private methods

    // MARK: > Setup

    private func controllerForTab(tab: Tab) -> UIViewController {
        let vc = tab.viewController
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

    // MARK: > Action

    dynamic private func sellButtonPressed() {
        openSell()
    }

    // MARK: > Deep link

    /**
    Opens a deep link.

    - parameter deepLink: The deep link.
    - returns: If succesfully handled opening the deep link.
    */
    func openDeepLink(deepLink: DeepLink) -> Bool {
        guard deepLink.isValid else { return false }

        var afterDelayClosure: (() -> Void)?
        switch deepLink.type {
        case .Home:
            switchToTab(.Home)
        case .Sell:
            openSell()
        case .Product:
            afterDelayClosure =  { [weak self] in
                let productId = deepLink.components[0]
                self?.openProductWithId(productId)
            }
        case .User:
            afterDelayClosure =  { [weak self] in
                let userId = deepLink.components[0]
                self?.openUserWithId(userId)
            }
        case .Chats:
            switchToTab(.Chats)
        case .Chat:

            // TODO: Refactor TabBarController with MVVM
            if let currentVC = selectedViewController as? UINavigationController,
                let topVC = currentVC.topViewController as? ChatViewController
                where (deepLink.query["p"] == topVC.viewModel.chat.product.objectId &&
                    deepLink.query["b"] == topVC.viewModel.otherUser?.objectId) {
                        topVC.refreshMessages()
            }
            else {
                switchToTab(.Chats)
                afterDelayClosure =  { [weak self] in
                    if let productId = deepLink.query["p"], let buyerId = deepLink.query["b"] {
                        self?.openChatWithProductId(productId, buyerId: buyerId)
                    }
                }
            }
        }
        if let afterDelayClosure = afterDelayClosure {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), afterDelayClosure)
        }
        return true
    }

    // MARK: > UI

    private func updateChatsBadge() {
        if let chatsTab = chatsTabBarItem {
            let badgeNumber = PushManager.sharedInstance.unreadMessagesCount
            chatsTab.badgeValue = badgeNumber > 0 ? "\(badgeNumber)" : nil
        }
    }

    private func openSell() {
        SellProductControllerFactory.presentSellProductOn(viewController: self, delegate: self)
    }

    private func openProductWithId(productId: String) {
        // Show loading
        showLoadingMessageAlert()

        // Retrieve the product
        productManager.retrieveProductWithId(productId) { [weak self] (result: ProductRetrieveServiceResult) in

            var loadingDismissCompletion: (() -> Void)? = nil

            // Success
            if let product = result.value {

                // Dismiss the loading and push the product vc on dismissal
                loadingDismissCompletion = { () -> Void in
                    if let navBarCtl = self?.selectedViewController as? UINavigationController {

                        // TODO: Refactor TabBarController with MVVM
                        let vm = ProductViewModel(product: product, tracker: TrackerProxy.sharedInstance)
                        let vc = ProductViewController(viewModel: vm)
                        navBarCtl.pushViewController(vc, animated: true)
                    }
                }
            } else if let error = result.error {
                // Error
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                loadingDismissCompletion = { () -> Void in
                    self?.showAutoFadingOutMessageAlert(message)
                }
            }

            // Dismiss loading
            self?.dismissLoadingMessageAlert(loadingDismissCompletion)
        }
    }

    private func openUserWithId(userId: String) {
        // Show loading
        showLoadingMessageAlert()

        // Retrieve the product
        userManager.retrieveUserWithId(userId) { [weak self] (result: UserRetrieveServiceResult) in

            var loadingDismissCompletion: (() -> Void)? = nil

            // Success
            if let user = result.value {

                // Dismiss the loading and push the product vc on dismissal
                loadingDismissCompletion = { () -> Void in
                    if let navBarCtl = self?.selectedViewController as? UINavigationController {

                        // TODO: Refactor TabBarController with MVVM
                        let vc = EditProfileViewController(user: user)
                        navBarCtl.pushViewController(vc, animated: true)
                    }
                }
            } else if let error = result.error {
                // Error
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                loadingDismissCompletion = { () -> Void in
                    self?.showAutoFadingOutMessageAlert(message)
                }
            }

            // Dismiss loading
            self?.dismissLoadingMessageAlert(loadingDismissCompletion)
        }
    }

    private func openChatWithProductId(productId: String, buyerId: String) {
        // Show loading
        showLoadingMessageAlert()

        ChatManager.sharedInstance.retrieveChatWithProductId(productId, buyerId: buyerId) {
            [weak self] (result: Result<Chat, ChatRetrieveServiceError>) -> Void in

            var loadingDismissCompletion: (() -> Void)? = nil

            // Success
            if let chat = result.value {

                // Dismiss the loading and push the product vc on dismissal
                loadingDismissCompletion = { () -> Void in
                    // TODO: Refactor TabBarController with MVVM
                    guard let navBarCtl = self?.selectedViewController as? UINavigationController else { return }
                    guard let viewModel = ChatViewModel(chat: chat) else { return }
                    let chatVC = ChatViewController(viewModel: viewModel)
                    navBarCtl.pushViewController(chatVC, animated: true)
                }
            } else if let error = result.error {
                // Error
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden:
                    message = LGLocalizedString.commonChatNotAvailable
                }

                loadingDismissCompletion = { () -> Void in
                    self?.showAutoFadingOutMessageAlert(message)
                }
            }

            // Dismiss loading
            self?.dismissLoadingMessageAlert(loadingDismissCompletion)
        }
    }

    private func switchToProfileOnTab(profileTab : EditProfileViewController.ProfileTab) {
        switchToTab(.Profile)

        // TODO: THIS IS DIRTY AND COUPLED! REFACTOR!
        guard let navBarCtl = selectedViewController as? UINavigationController else { return }
        guard let rootViewCtrl = navBarCtl.topViewController, let profileViewCtrl = rootViewCtrl
            as? EditProfileViewController else { return }

        switch profileTab {
        case .ProductImSelling:
            profileViewCtrl.showSellProducts(self)
        case .ProductISold:
            profileViewCtrl.showSoldProducts(self)
        case .ProductFavourite:
            profileViewCtrl.showFavoritedProducts(self)
        }
    }

    // MARK: > NSNotification

    @objc private func unreadMessagesDidChange(notification: NSNotification) {
        updateChatsBadge()
    }

    @objc private func logout(notification: NSNotification) {

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

    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        // Update unread messages
        PushManager.sharedInstance.updateUnreadMessagesCount()
    }

    dynamic private func askUserToUpdateLocation() {

        let firstAlert = UIAlertController(title: nil, message: LGLocalizedString.changeLocationAskUpdateLocationMessage,
            preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: LGLocalizedString.commonOk, style: UIAlertActionStyle.Default) {
            (updateToGPSLocation) -> Void in
            MyUserManager.sharedInstance.setAutomaticLocationWithPlace(nil)
        }
        let noAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel) {
            (showSecondAlert) -> Void in
            let secondAlert = UIAlertController(title: nil,
                message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil)
            let updateAction = UIAlertAction(title: LGLocalizedString.changeLocationConfirmUpdateButton,
                style: .Default) { (updateToGPSLocation) -> Void in
                    MyUserManager.sharedInstance.setAutomaticLocationWithPlace(nil)
            }
            secondAlert.addAction(cancelAction)
            secondAlert.addAction(updateAction)
            
            self.presentViewController(secondAlert, animated: true, completion: nil)
        }
        firstAlert.addAction(yesAction)
        firstAlert.addAction(noAction)
        
        self.presentViewController(firstAlert, animated: true, completion: nil)
        
        // We should ask only one time
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: MyUserManager.Notification.didMoveFromManualLocationNotification.rawValue, object: nil)
    }
}
