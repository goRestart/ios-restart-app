//
//  UIViewController+User.swift
//  LetGo
//
//  Created by AHL on 18/6/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum LoginStyle {
    case fullScreen
    case popup(String)
}

extension UIViewController {
    
    internal func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {
            ifLoggedInThen(source, loginStyle: .fullScreen, preDismissAction: nil, loggedInAction: loggedInAction,
                elsePresentSignUpWithSuccessAction: afterLogInAction)
    }

    internal func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle,
        preDismissAction: (() -> Void)?, loggedInAction: () -> Void,
        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {
            if Core.sessionManager.loggedIn {
                loggedInAction()
            } else {
                let viewModel = SignUpViewModel(appearance: .Light, source: source)
                switch loginStyle {
                case .fullScreen:
                    let vc = MainSignUpViewController(viewModel: viewModel)
                    vc.afterLoginAction = afterLogInAction
                    let navCtl = UINavigationController(rootViewController: vc)
                    navCtl.view.backgroundColor = UIColor.white
                    present(navCtl, animated: true, completion: nil)
                case .popup(let message):
                    let vc = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
                    vc.preDismissAction = preDismissAction
                    vc.afterLoginAction = afterLogInAction
                    present(vc, animated: true, completion: nil)
                }
            }
    }
}
