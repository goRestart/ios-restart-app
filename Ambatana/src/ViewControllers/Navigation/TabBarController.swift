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

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // Constants & enums
    private static let tooltipVerticalSpacingAnimBottom: CGFloat = 10
    private static let tooltipVerticalSpacingAnimTop: CGFloat = 30
    
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
        
        var viewController: UIViewController {
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
                let vc = EditProfileViewController()
                vc.userObject = PFUser.currentUser()
                return vc
            }
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
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // If tooltip is displayed then animate it
        let tooltipIsShown = tooltip.superview != nil
        if tooltipIsShown {
            startTooltipAnimation()
        }
        
        // Update the badge
        updateBadge()
        
        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "badgeChanged:", name: kLetGoUserBadgeChangedNotification, object: nil)
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
    
    func openChats() {
        if let navBarCtl = selectedViewController as? UINavigationController {
            // Pop the navigation back to root
            navBarCtl.popToRootViewControllerAnimated(false)
            // Change the tab to chats
            selectedIndex = Tab.Chats.rawValue
        }
    }
    
    func dismissTooltip() {
        tooltipPressed()
    }
    
    func displayMessage(message: String) {
        showAutoFadingOutMessageAlert(message)
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // If SellVC is contained in a NavCtl, then do not allow selecting it
        if let navVC = viewController as? UINavigationController {
            if let sellVC = navVC.topViewController as? SellProductViewController {
                return false
            }
        }
        // Or, its the SellVC perse, then do not allow selecting it
        else if let sellVC = viewController as? SellProductViewController {
            return false
        }
        return true
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func controllerForTab(tab: Tab) -> UIViewController {
        let iconInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
        let vc = tab.viewController
        let navCtl = UINavigationController(rootViewController: vc)
        let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)
        // Customize the selected appereance
        tabBarItem.image = tabBarItem.selectedImage.imageWithColor(StyleHelper.tabBarIconUnselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.imageInsets = iconInsets
        navCtl.tabBarItem = tabBarItem
        return navCtl
    }
    
    // MARK: > Action
    
    dynamic private func sellButtonPressed() {
        dismissTooltip()
        
        let vc = Tab.Sell.viewController
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    dynamic private func tooltipPressed() {
        // Kill all current animations
        tooltip.pop_removeAllAnimations()
        
        // Fade it out and remove from superview when done
        startTooltipFadeOut({ [weak self] in
            if let strongSelf = self {
                strongSelf.tooltip.removeFromSuperview()
            }
        })
    }
    
    // MARK: > Animation
    
    private func startTooltipAnimation() {
        if tooltip.superview == nil {
            return
        }
        
        // Loop between move up & down
        startTooltipMoveUpAnimation { [weak self] in
            if let strongSelf = self {
                strongSelf.startTooltipMoveDownAnimation { [weak self] in
                    if let strongSelf = self {
                        strongSelf.startTooltipAnimation()
                    }
                }
            }
        }
    }
    
    private func startTooltipMoveUpAnimation(completion: () -> Void) {
        if tooltip == nil || tooltip.superview == nil {
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
    
    private func startTooltipMoveDownAnimation(completion: () -> Void) {
        if tooltip == nil || tooltip.superview == nil {
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
    
    private func startTooltipFadeOut(completion: () -> Void) {
        if tooltip == nil || tooltip.superview == nil {
            return
        }
        
        let alphaAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        alphaAnimation.toValue = 0
        alphaAnimation.removedOnCompletion = true
        alphaAnimation.completionBlock = { (animation: POPAnimation!, finished: Bool) -> Void in
            completion()
        }
        
        tooltip.pop_addAnimation(alphaAnimation, forKey: "alphaAnimation")
    }

    private var tooltipAnimTopCenter: CGPoint {
        return CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimTop)
    }
    
    private var tooltipAnimBottomCenter: CGPoint {
        return CGPoint(x: view.center.x, y: view.frame.size.height - tabBar.frame.height - 0.5 * tooltip.frame.size.height - TabBarController.tooltipVerticalSpacingAnimBottom)
    }
    
    // MARK: > Badge
    
    private func updateBadge() {
        if let chatsTab = chatsTabBarItem {
            let badgeNumber = PFInstallation.currentInstallation().badge
            chatsTab.badgeValue = badgeNumber > 0 ? "\(badgeNumber)" : nil
        }
    }
    
    // MARK: > NSNotification
    
    @objc private func badgeChanged(notification: NSNotification) {
        updateBadge()
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {
        updateBadge()
    }
}
