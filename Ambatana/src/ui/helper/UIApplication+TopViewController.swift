//
//  UIApplication+TopViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

// Ref: https://gist.github.com/snikch/3661188
extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}