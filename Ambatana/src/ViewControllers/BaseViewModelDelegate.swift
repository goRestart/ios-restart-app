//
//  BaseViewModelDelegate.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol BaseViewModelDelegate: class {
    func vmShowAutoFadingMessage(message: String, completion: (() -> ())?)

    func vmShowLoading(loadingMessage: String?)
    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?)

    func vmShowAlertWithTitle(title: String, text: String, alertType: AlertType, actions: [UIAction]?)
    func vmShowAlert(title: String?, message: String?, actions: [UIAction])
    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction])
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction])
    func vmShowActionSheet(cancelLabel: String, actions: [UIAction])
    func ifLoggedInThen(source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                                 elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void)
    func ifLoggedInThen(source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void)

    func vmPop()
    func vmDismiss(completion: (() -> Void)?)
}

extension UIViewController: BaseViewModelDelegate {
    func vmShowAutoFadingMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }

    func vmShowLoading(loadingMessage: String?) {
        showLoadingMessageAlert(loadingMessage)
    }

    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        dismissLoadingMessageAlert(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }

    func vmShowAlert(title: String?, message: String?, actions: [UIAction]) {
        showAlert(title, message: message, actions: actions)
    }

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        showAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }

    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, completion: nil)
    }

    func vmShowActionSheet(cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: nil)
    }

    func vmPop() {
        navigationController?.popViewControllerAnimated(true)
    }

    func vmDismiss(completion: (() -> Void)?) {
        dismissViewControllerAnimated(true, completion: completion)
    }
    
    func vmShowAlertWithTitle(title: String, text: String, alertType: AlertType, actions: [UIAction]?) {
        guard let alert = LGAlertViewController(title: title, text: text, alertType: alertType, actions: actions) else {
            return
        }
        let presenter: UIViewController = tabBarController ?? navigationController ?? self
        presenter.presentViewController(alert, animated: true, completion: nil)
    }

    func ifLoggedInThen(source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {
        ifLoggedInThen(source, loginStyle: loginStyle, preDismissAction: nil, loggedInAction: loggedInAction,
                       elsePresentSignUpWithSuccessAction: afterLogInAction)
    }
}
