//
//  NavigationHelper.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class NavigationHelper {
 
    public static func isTabBarControllerPresent() -> Bool {
        let tabBarCtl = UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentedViewController as? TabBarController
        return tabBarCtl != nil
    }
    
    public static func currentTabBarViewController() -> UIViewController? {
        if let tabBarCtl = UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentedViewController as? TabBarController {
            
            // If the selected VC is a navigation controller, then return the one on top
            let selectedVC = tabBarCtl.selectedViewController
            if let navCtl = tabBarCtl.selectedViewController as? UINavigationController, let topVC = navCtl.topViewController {
                return topVC
            }
        }
        return nil
    }
}
