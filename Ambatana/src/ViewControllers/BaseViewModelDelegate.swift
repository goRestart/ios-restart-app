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

    func vmShowAlert(title: String?, message: String?, actions: [UIAction])
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction])

    func ifLoggedInThen(source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                                 elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void)

    func vmPop()
}

extension BaseViewModelDelegate {
    func vmShowActionSheet(cancelLabel: String, actions: [UIAction]) {
        let cancelAction = UIAction(interface: .Text(cancelLabel), action: {})
        vmShowActionSheet(cancelAction, actions: actions)
    }

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        let cancelAction = UIAction(interface: .StyledText(cancelLabel, .Cancel), action: {})
        let totalActions = [cancelAction] + actions
        vmShowAlert(title, message: message, actions: totalActions)
    }
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

    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions)
    }

    func vmPop() {
        navigationController?.popViewControllerAnimated(true)
    }
}