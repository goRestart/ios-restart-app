//
//  UIViewController+User.swift
//  LetGo
//
//  Created by AHL on 18/6/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension UIViewController {
    
    internal func ifLoggedInThen(source: TrackingParameterLoginSourceValue, loggedInAction: () -> Void, elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {
        let isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
        if isLogInRequired {
            let vc = MainSignUpViewController(source: source)
            vc.afterLoginAction = afterLogInAction

            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
            navCtl.navigationBar.shadowImage = UIImage()
            
            self.presentViewController(navCtl, animated: true, completion: nil)
        }
        else {
            loggedInAction()
        }
    }
}
