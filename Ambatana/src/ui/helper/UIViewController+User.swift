//
//  UIViewController+User.swift
//  LetGo
//
//  Created by AHL on 18/6/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension UIViewController {
    
    internal func ifLoggedInThen(source: EventParameterLoginSourceValue, loggedInAction: () -> Void, elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {
        let isLogInRequired = MyUserRepository.sharedInstance.myUser == nil
        if isLogInRequired {
            loggedInAction()
        } else {
            let vc = MainSignUpViewController(source: source)
            vc.afterLoginAction = afterLogInAction
            
            let navCtl = UINavigationController(rootViewController: vc)
            navCtl.view.backgroundColor = UIColor.whiteColor()
            presentViewController(navCtl, animated: true, completion: nil)
        }
    }
}
