//
//  UIViewController+Alert.swift
//  LetGo
//
//  Created by Albert Hernández López on 04/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


// TODO: Eventually these extensions should be removed. All alert handling should be presented/dismissed via coordinator
import UIKit

private struct AlertKeys {
    static var LoadingKey = 0
}
private let kLetGoFadingAlertDismissalTime: Double = 2.5



// MARK: - Manual dismiss alert

extension UIViewController {
    private var loading: UIAlertController? {
        get {
            return (objc_getAssociatedObject(self, &AlertKeys.LoadingKey) as? UIAlertController)
        }
        set {
            objc_setAssociatedObject(
                self,
                &AlertKeys.LoadingKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }


    // Shows a loading alert message. It will not fade away, so must be explicitly dismissed by calling dismissAlert()
    func showLoadingMessageAlert(message: String? = LGLocalizedString.commonLoading) {
        guard self.loading == nil else { return }

        let finalMessage = (message ?? LGLocalizedString.commonLoading)+"\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        self.loading = alert
        presentViewController(alert, animated: true, completion: nil)
    }

    // dismisses a previously shown loading alert message
    func dismissLoadingMessageAlert(completion: (() -> Void)? = nil) {
        if let alert = self.loading {
            self.loading = nil
            if let _ = alert.presentingViewController {
                alert.dismissViewControllerAnimated(true, completion: completion)
            } else {
                completion?()
            }
        } else {
            completion?()
        }
    }

    // dismisses a previously shown loading alert message displaying a finished alert message
    func dismissLoadingMessageAlert(finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        let completion: (() -> ())?
        if let message = finishedMessage {
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message, time: 3, completion: afterMessageCompletion)
            }
        } else if let afterMessageCompletion = afterMessageCompletion {
            completion = afterMessageCompletion
        } else {
            completion = nil
        }
        dismissLoadingMessageAlert(completion)
    }
}


// MARK: - Auto dismiss alert

extension UIViewController {
    // Shows an alert message that fades out after kLetGoFadingAlertDismissalTime seconds
    func showAutoFadingOutMessageAlert(message: String, time: Double = kLetGoFadingAlertDismissalTime,
                                       completion: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        presentViewController(alert, animated: true, completion: nil)
        delay(time) {
            alert.dismissViewControllerAnimated(true) { _ in completion?() }
        }
    }
}


// MARK: - Alerts w UIAction

extension UIViewController {

    func showAlert(title: String?, message: String?, actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }

            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        presentViewController(alert, animated: true, completion: completion)
    }

    func showAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        let cancelAction = UIAction(interface: .StyledText(cancelLabel, .Cancel), action: {})
        let totalActions = [cancelAction] + actions
        showAlert(title, message: message, actions: totalActions)
    }

    func showAlertWithTitle(title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        guard let alert = LGAlertViewController(title: title, text: text, alertType: alertType, actions: actions) else {
            return
        }
        let presenter: UIViewController = tabBarController ?? navigationController ?? self
        presenter.presentViewController(alert, animated: true, completion: nil)
    }

    func showActionSheet(cancelAction: UIAction, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil,
                         completion: (() -> Void)? = nil) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: barButtonItem, sourceView: nil, sourceRect: nil,
                        completion: completion)
    }
    
    func showActionSheet(cancelAction: UIAction, actions: [UIAction], sourceView: UIView? = nil,
                         sourceRect: CGRect? = nil, completion: (() -> Void)? = nil) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, sourceView: sourceView,
                        sourceRect: sourceRect, completion: completion)
    }

    func showActionSheet(cancelLabel: String, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil) {
        let cancelAction = UIAction(interface: .Text(cancelLabel), action: {})
        showActionSheet(cancelAction, actions: actions, barButtonItem: barButtonItem, sourceView: nil,
                        sourceRect: nil, completion: nil)
    }
    
    func showActionSheet(cancelLabel: String, actions: [UIAction], sourceView: UIView? = nil,
                         sourceRect: CGRect? = nil) {
        let cancelAction = UIAction(interface: .Text(cancelLabel), action: {})
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, sourceView: sourceView,
                        sourceRect: sourceRect, completion: nil)
    }
    
    private func showActionSheet(cancelAction: UIAction, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil,
                                 sourceView: UIView? = nil, sourceRect: CGRect? = nil,
                                 completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if let item = barButtonItem {
            alert.popoverPresentationController?.barButtonItem = item
        } else if let sourceView = sourceView, let sourceRect = sourceRect {
            alert.popoverPresentationController?.sourceRect = sourceRect
            alert.popoverPresentationController?.sourceView = sourceView
        } else if DeviceFamily.isiPad {
            showAlert(nil, message: nil, actions: actions, completion: completion)
            return
        }
        
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
        
        presentViewController(alert, animated: true, completion: completion)
    }
}
