//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    // Constants & enums
    
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
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        // Move the sell button, @ahl: can be tested enabling rotation
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
    
    func sellButtonPressed() {
        let vc = Tab.Sell.viewController
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
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
