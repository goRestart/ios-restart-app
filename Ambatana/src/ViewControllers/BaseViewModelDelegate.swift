//
//  BaseViewModelDelegate.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol BaseViewModelDelegate: class {
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?)

    func vmShowLoading(_ loadingMessage: String?)
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?)

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?)
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?)
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?)
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?)
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction])
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction])
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction])
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction])

    func vmPop()
    func vmDismiss(_ completion: (() -> Void)?)
    
    func vmOpenInternalURL(_ url: URL)
}

extension UIViewController: BaseViewModelDelegate {
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completion: completion)
    }

    func vmShowLoading(_ loadingMessage: String?) {
        showLoadingMessageAlert(loadingMessage)
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        dismissLoadingMessageAlert(finishedMessage, afterMessageCompletion: afterMessageCompletion)
    }

    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        showAlert(title, message: message, actions: actions)
    }

    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        showAlert(title, message: message, cancelLabel: cancelLabel, actions: actions)
    }

    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, completion: nil)
    }

    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {
        showActionSheet(cancelLabel, actions: actions, barButtonItem: nil)
    }

    func vmPop() {
        _ = navigationController?.popViewController(animated: true)
    }

    func vmDismiss(_ completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        showAlertWithTitle(title, text: text, alertType: alertType, actions: actions)
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {
        showAlertWithTitle(title, text: text, alertType: alertType, actions: actions, dismissAction: dismissAction)
    }
    
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {
        showAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions, dismissAction: dismissAction)
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout,
                              actions: [UIAction]?) {
        showAlertWithTitle(title, text: text, alertType: alertType, buttonsLayout: buttonsLayout, actions: actions)
    }

    func vmOpenInternalURL(_ url: URL) {
        openInternalUrl(url)
    }
}
