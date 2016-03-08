//
//  BaseViewModelDelegate.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol BaseViewModelDelegate: class {
    func vmShowLoading(loadingMessage: String?)
    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?)

    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction])
    func vmShowActionSheet(cancelLabel: String, actions: [UIAction])

    func vmPop()
}

extension BaseViewController: BaseViewModelDelegate {
    func vmShowLoading(loadingMessage: String?) {
        showLoadingMessageAlert(loadingMessage)
    }

    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        let completion: (() -> ())?
        if let message = finishedMessage {
            completion = {
                self.showAutoFadingOutMessageAlert(message, time: 3, completionBlock: afterMessageCompletion)
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
            let action = UIAlertAction(title: title, style: .Default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        presentViewController(alert, animated: true, completion: nil)
    }

    func vmShowActionSheet(cancelLabel: String, actions: [UIAction]) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }
            let action = UIAlertAction(title: title, style: .Default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: cancelLabel, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)

        presentViewController(alert, animated: true, completion: nil)
    }

    func vmPop() {
        navigationController?.popViewControllerAnimated(true)
    }
}