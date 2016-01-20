//
//  UIViewController+User.swift
//  LetGo
//
//  Created by AHL on 18/6/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum LoginStyle {
    case FullScreen
    case Popup(String)
}

extension UIViewController {
    
    internal func ifLoggedInThen(source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
        elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {
            ifLoggedInThen(source, loginStyle: .FullScreen, loggedInAction: loggedInAction,
                elsePresentSignUpWithSuccessAction: afterLogInAction)
    }

    internal func ifLoggedInThen(source: EventParameterLoginSourceValue, loginStyle: LoginStyle,
        loggedInAction: () -> Void, elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {
            if MyUserRepository.sharedInstance.loggedIn {
                loggedInAction()
            } else {
                let viewModel = SignUpViewModel(source: source)
                switch loginStyle {
                case .FullScreen:
                    let vc = MainSignUpViewController(viewModel: viewModel)
                    vc.afterLoginAction = afterLogInAction
                    let navCtl = UINavigationController(rootViewController: vc)
                    navCtl.view.backgroundColor = UIColor.whiteColor()
                    presentViewController(navCtl, animated: true, completion: nil)
                case .Popup(let message):
                    let vc = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
                    vc.afterLoginAction = afterLogInAction
                    presentViewController(vc, animated: true, completion: nil)
                }
            }
    }
}
