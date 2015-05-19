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

    // Constants
    private static let customSellButtonIndex: CGFloat = 2
    
    // UI
    var sellButton: UIButton!
    
    // MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Products
        let iconInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
        let productsVC = ProductsViewController()
        let productsNav = UINavigationController(rootViewController: productsVC)
        let productsTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_home"), selectedImage: nil)
        productsTabBarItem.imageInsets = iconInsets
        productsNav.tabBarItem = productsTabBarItem
        
        // Categories
        let categoriesVC = CategoriesViewController()
        let categoriesNav = UINavigationController(rootViewController: categoriesVC)
        let categoriesTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_categories"), selectedImage: nil)
        categoriesTabBarItem.imageInsets = iconInsets
        categoriesNav.tabBarItem = categoriesTabBarItem
        
        // Sell
        let sellVC = SellProductViewController()
        let sellNav = UINavigationController(rootViewController: sellVC)
        let sellTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_sell"), selectedImage: nil)
        sellTabBarItem.imageInsets = iconInsets
        sellNav.tabBarItem = sellTabBarItem
        
        // Chats
        let chatsVC = ChatListViewController()
        let chatsNav = UINavigationController(rootViewController: chatsVC)
        let chatsTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_chats"), selectedImage: nil)
        chatsTabBarItem.imageInsets = iconInsets
        chatsNav.tabBarItem = chatsTabBarItem
        
        // Profile
        let profileVC = EditProfileViewController()
        profileVC.userObject = PFUser.currentUser()
        let profileNav = UINavigationController(rootViewController: profileVC)
        let profileTabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_profile"), selectedImage: nil)
        profileTabBarItem.imageInsets = iconInsets
        profileNav.tabBarItem = profileTabBarItem
        
        // Setup
        viewControllers = [productsNav, categoriesNav, sellNav, chatsNav, profileNav]
        delegate = self
        
        // Customize the selected appereance
        for item in [productsTabBarItem, categoriesTabBarItem, sellTabBarItem, chatsTabBarItem, profileTabBarItem] {
            item.image = item.selectedImage.imageWithColor(StyleHelper.tabBarIconUnselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }
        
        // Add the sell button as a custom one
        let itemIndex = TabBarController.customSellButtonIndex
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton = UIButton(frame: CGRect(x: itemWidth * itemIndex, y: 0, width: itemWidth, height: tabBar.frame.height))
        sellButton.addTarget(self, action: Selector("sellButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: "tabbar_sell"), forState: UIControlState.Normal)
        sellButton.backgroundColor = StyleHelper.tabBarSellIconBgColor
        tabBar.addSubview(sellButton)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillLayoutSubviews() {
        
        // Move the sell button, @ahl: can be tested enabling rotation
        let itemIndex = TabBarController.customSellButtonIndex
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton.frame = CGRect(x: itemWidth * itemIndex, y: 0, width: itemWidth, height: tabBar.frame.height)
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
    
    // MARK: - Internal methods
    
    func sellButtonPressed() {
        let vc = SellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }

}
