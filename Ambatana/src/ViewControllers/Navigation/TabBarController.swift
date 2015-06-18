//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import pop
import UIKit

class TabBarController: UITabBarController, SellProductViewControllerDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate {

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
                return ProductsViewController()
            case Categories:
                return CategoriesViewController()
            case Sell:
                return SellProductViewController()
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
            return Array(SequenceOf { () -> GeneratorOf<Tab> in
                    var i = 0
                    return GeneratorOf<Tab>{
                        return Tab(rawValue: i++)
                    }
                }
            )
        }
    }
    
    // UI
    var tooltip: UIButton!
    var sellButton: UIButton!
    var chatsTabBarItem: UITabBarItem?
    
    // MARK: - Lifecycle
    
    init() {
       super.init(nibName: nil, bundle: nil)
        
        // Generate the view controllers
        var vcs: [UIViewController] = []
        let iconInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
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
        sellButton = UIButton(frame: CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth, height: tabBar.frame.height))
        sellButton.addTarget(self, action: Selector("sellButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: Tab.Sell.tabIconImageName), forState: UIControlState.Normal)
        sellButton.backgroundColor = StyleHelper.tabBarSellIconBgColor
        tabBar.addSubview(sellButton)
        
        // Add the tooltip
        let tooltipImage = UIImage(named: "tabbar_tooltip")!
        tooltip = UIButton(frame: CGRect(x: 0, y: 0, width: tooltipImage.size.width, height: tooltipImage.size.height))
        tooltip.addTarget(self, action: Selector("tooltipPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        tooltip.center = CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.75 * tooltip.frame.size.height)
        tooltip.contentMode = UIViewContentMode.Top
        tooltip.setImage(tooltipImage, forState: UIControlState.Normal)
        view.addSubview(tooltip)
        
        // Initially set the chats tab badge to the app icon badge number
        if let chatsTab = chatsTabBarItem {
            let applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
            chatsTab.badgeValue = applicationIconBadgeNumber > 0 ? "\(applicationIconBadgeNumber)" : nil
        }
        
        // Update chats badge
        updateChatsBadge()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If tooltip is displayed then animate it
        let tooltipIsShown = tooltip.superview != nil
        if tooltipIsShown {
            showTooltip()
        }
        
        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unreadMessagesDidChange:", name: PushManager.Notification.unreadMessagesDidChange.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        
        // @ahl: can be tested enabling rotation
        
        // Center the tooltip
        tooltip.center = CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height)
        
        // Move the sell button
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton.frame = CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth, height: tabBar.frame.height)
    }
    
    // MARK: - Public / Internal methods
    
    /**
        Pops the current navigation controller to root and switches to the given tab.
        
        :param: The tab to go to.
    */
    func switchToTab(tab: Tab) {
        if let navBarCtl = selectedViewController as? UINavigationController {
            // Pop the navigation back to root
            navBarCtl.popToRootViewControllerAnimated(false)
            // Change the tab to chats
            selectedIndex = tab.rawValue
        }
    }
    
    /**
        Shows the tooltip and starts its bounce animation.
    */
    func showTooltip() {
        if tooltip.superview == nil {
            view.addSubview(tooltip)
        }
        
        startTooltipBounceAnimation()
    }
    
    /**
        Dismissed the tooltip.
    
        :param: animated If it show be dismissed with an animation.
    */
    func dismissTooltip(#animated: Bool) {
        let removeFromSuperview: () -> Void = { [weak self] in
            self?.tooltip.removeFromSuperview()
        }
        if animated {
            startTooltipFadeOutAnimation(removeFromSuperview)
        }
        else {
            removeFromSuperview()
        }
    }
    
    /**
        Displays a message to the user.
        
        :param: message The message.
    */
    func displayMessage(message: String) {
        showAutoFadingOutMessageAlert(message)
    }
    
    // MARK: - SellProductViewControllerDelegate
    func sellProductViewController(sellVC: SellProductViewController?, didCompleteSell successfully: Bool) {
        if successfully {
            switchToTab(.Profile)
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        // When navigating deeper
        if navigationController.viewControllers.count > 1 {
            // Dismisses the tooltip, if present, when pushing a vc that's not a ProductsViewController / CategoriesViewController
            let shouldKeepTooltip = viewController is ProductsViewController || viewController is CategoriesViewController
            if !shouldKeepTooltip {
                dismissTooltip(animated: false)
            }
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        var isLogInRequired = false
        
        // If it's a NavCtl
        if let navVC = viewController as? UINavigationController {
            
            // Do not allow selecting Sell
            if let sellVC = navVC.topViewController as? SellProductViewController {
                return false
            }
            // Do not allow selecting Chats if it's an anonymous user
            else if let chatsVC = navVC.topViewController as? ChatListViewController {
                isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
            }
            // Do not allow selecting Profile if it's an anonymous user
            else if let profileVC = navVC.topViewController as? EditProfileViewController {
                
                // Update the user in my profile
                if let user = MyUserManager.sharedInstance.myUser() {
                    profileVC.user = user
                }
                
                isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
            }
            
        }
        // Or, its the SellVC perse, then do not allow selecting it
        else if let sellVC = viewController as? SellProductViewController {
            return false
        }
        
        // If log in is required then present the login vc
        if isLogInRequired {
            let vc = MainSignUpViewController()
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            navCtl.navigationBar.shadowImage = UIImage()
            self.presentViewController(navCtl, animated: true, completion: nil)
        }
        
        return !isLogInRequired
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func controllerForTab(tab: Tab) -> UIViewController {
        let vc = tab.viewController
        let navCtl = UINavigationController(rootViewController: vc ?? UIViewController())
        navCtl.delegate = self
       
        
        let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)

        // Customize the selected appereance
        tabBarItem.image = tabBarItem.selectedImage.imageWithColor(StyleHelper.tabBarIconUnselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
        
        navCtl.tabBarItem = tabBarItem
        return navCtl
    }
    
    // MARK: > Action
    
    dynamic private func sellButtonPressed() {
        // Dismiss the tooltip, if present
        dismissTooltip(animated: true)
        
        // If not logged in then present the login VC
        let isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
        if isLogInRequired {
            let vc = MainSignUpViewController()
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            navCtl.navigationBar.shadowImage = UIImage()
            self.presentViewController(navCtl, animated: true, completion: nil)
        }
        // Otherwise, present the sell VC
        else if let vc = Tab.Sell.viewController as? SellProductViewController {
            vc.delegate = self
            let navCtl = UINavigationController(rootViewController: vc)
            presentViewController(navCtl, animated: true, completion: nil)
        }
    }
    
    dynamic private func tooltipPressed() {
        // Dismiss the tooltip, if present
        dismissTooltip(animated: true)
    }
    
    // MARK: > UI
    
    private func updateChatsBadge() {
        if let chatsTab = chatsTabBarItem {
            let badgeNumber = PushManager.sharedInstance.unreadMessagesCount
            chatsTab.badgeValue = badgeNumber > 0 ? "\(badgeNumber)" : nil
        }
    }
    
    // MARK: > NSNotification
    
    @objc private func unreadMessagesDidChange(notification: NSNotification) {
        updateChatsBadge()
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        // If we're showing a product list or the categories view, then show again the tooltip
        let topVC = UIApplication.topViewController()
        if topVC is ProductsViewController || topVC is CategoriesViewController {
            showTooltip()
        }
    }
    
    // MARK: > Animation
    
    // MARK: >> Tooltip bounce
    
    private func startTooltipBounceAnimation() {
        if tooltip.superview == nil {
            return
        }
        
        // Remove all animations
        tooltip.pop_removeAllAnimations()
        
        // It should be visible
        tooltip.alpha = 1
        
        // Loop between move up & down
        startTooltipBounceUpAnimation { [weak self] in
            if let strongSelf = self {
                strongSelf.startTooltipBounceDownAnimation { [weak self] in
                    if let strongSelf = self {
                        strongSelf.startTooltipBounceAnimation()
                    }
                }
            }
        }
    }
    
    private func startTooltipBounceUpAnimation(completion: () -> Void) {
        if tooltip.superview == nil {
            return
        }
        
        let centerUp = CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimTop)
        let centerDown = CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimBottom)
        
        let up = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        up.fromValue = NSValue(CGPoint: tooltipAnimBottomCenter)
        up.toValue = NSValue(CGPoint: tooltipAnimTopCenter)
        up.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        up.completionBlock = { (animation: POPAnimation!, finished: Bool) -> Void in
            if finished {
                completion()
            }
        }
        tooltip.pop_addAnimation(up, forKey: "up")
        
    }
    
    private func startTooltipBounceDownAnimation(completion: () -> Void) {
        if tooltip.superview == nil {
            return
        }
        
        let down = POPBasicAnimation(propertyNamed: kPOPViewCenter)
        down.fromValue = NSValue(CGPoint: tooltipAnimTopCenter)
        down.toValue = NSValue(CGPoint: tooltipAnimBottomCenter)
        down.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        down.completionBlock = { [weak self] (animation: POPAnimation!, finished: Bool) -> Void in
            if finished {
                completion()
            }
        }
        tooltip.pop_addAnimation(down, forKey: "down")
    }
    
    private var tooltipAnimTopCenter: CGPoint {
        return CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimTop)
    }
    
    private var tooltipAnimBottomCenter: CGPoint {
        return CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimBottom)
    }
    
    // MARK: >> Tooltip fade in
    
    private func startTooltipFadeInAnimation(completion: () -> Void) {
        if tooltip.superview == nil {
            return
        }
        
        // Remove all animations
        tooltip.pop_removeAllAnimations()
        
        // Perform the animation
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation.toValue = 1
        alphaAnimation.removedOnCompletion = true
        alphaAnimation.completionBlock = { (animation: POPAnimation!, finished: Bool) -> Void in
            completion()
        }
        tooltip.pop_addAnimation(alphaAnimation, forKey: "fade in")
    }
    
    // MARK: >> Tooltip fade out

    private func startTooltipFadeOutAnimation(completion: () -> Void) {
        if tooltip.superview == nil {
            return
        }
        
        // Remove all animations
        tooltip.pop_removeAllAnimations()
        
        // Perform the animation, on completion remove it from superview
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation.toValue = 0
        alphaAnimation.removedOnCompletion = true
        alphaAnimation.completionBlock = { [weak self] (animation: POPAnimation!, finished: Bool) -> Void in
            self?.tooltip.removeFromSuperview()
        }
        
        tooltip.pop_addAnimation(alphaAnimation, forKey: "alphaAnimation")
    }
}
