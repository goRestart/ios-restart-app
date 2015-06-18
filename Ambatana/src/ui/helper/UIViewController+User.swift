//
//  UIViewController+User.swift
//  LetGo
//
//  Created by AHL on 18/6/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension UIViewController {
    
    internal func ifLoggedInThen(loggedInAction: () -> Void, elsePresentSignUpWithSuccessAction afterLoggedInAction: () -> Void) {
        let isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
        if isLogInRequired {
            let vc = MainSignUpViewController()
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            navCtl.navigationBar.shadowImage = UIImage()
            // TODO: Place after logged in action
            self.presentViewController(navCtl, animated: true, completion: nil)
        }
        else {
            loggedInAction()
        }
    }
}
