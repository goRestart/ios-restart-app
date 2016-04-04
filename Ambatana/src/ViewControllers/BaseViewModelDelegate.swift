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

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction])
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction])

    func vmPop()
}

extension BaseViewModelDelegate {
    func vmShowActionSheet(cancelLabel: String, actions: [UIAction]) {
        let cancelAction = UIAction(interface: .Text(cancelLabel), action: {})
        vmShowActionSheet(cancelAction, actions: actions)
    }
}

extension BaseViewController: BaseViewModelDelegate {
    func vmShowAutoFadingMessage(message: String, completion: (() -> ())?) {
        showAutoFadingOutMessageAlert(message, completionBlock: completion)
    }

    func vmShowLoading(loadingMessage: String?) {
        showLoadingMessageAlert(loadingMessage)
    }

    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        let completion: (() -> ())?
        if let message = finishedMessage {
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message, time: 3, completionBlock: afterMessageCompletion)
            }
        } else {
            completion = nil
        }
        dismissLoadingMessageAlert(completion)
    }

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: cancelLabel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }

            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        presentViewController(alert, animated: true, completion: nil)
    }

    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }
            let action = UIAlertAction(title: title, style: .Default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: cancelAction.text, style: .Cancel, handler: { _ in
            cancelAction.action()
        })
        alert.addAction(cancelAction)

        presentViewController(alert, animated: true, completion: nil)
    }

    func vmPop() {
        navigationController?.popViewControllerAnimated(true)
    }
}