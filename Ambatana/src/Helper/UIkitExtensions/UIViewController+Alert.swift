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
    func showLoadingMessageAlert(_ message: String? = LGLocalizedString.commonLoading) {
        guard self.loading == nil else { return }

        let finalMessage = (message ?? LGLocalizedString.commonLoading)+"\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.black
        activityIndicator.center = CGPoint(x: 130.5, y: 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        self.loading = alert
        present(alert, animated: true, completion: nil)
    }

    // dismisses a previously shown loading alert message
    func dismissLoadingMessageAlert(_ completion: (() -> Void)? = nil) {
        if let alert = self.loading {
            self.loading = nil
            if let _ = alert.presentingViewController {
                alert.dismiss(animated: true, completion: completion)
            } else {
                completion?()
            }
        } else {
            completion?()
        }
    }

    // dismisses a previously shown loading alert message displaying a finished alert message
    func dismissLoadingMessageAlert(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
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
    func showAutoFadingOutMessageAlert(_ message: String, time: Double = kLetGoFadingAlertDismissalTime,
                                       completion: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        delay(time) {
            alert.dismiss(animated: true) { _ in completion?() }
        }
    }
}


// MARK: - Alerts w UIAction

extension UIViewController {

    func showAlert(_ title: String?, message: String?, actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }

            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }

        let presenter: UIViewController = tabBarController ?? navigationController ?? self
        presenter.present(alert, animated: true, completion: completion)
    }

    func showAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction], completion: (() -> Void)? = nil) {
        let cancelAction = UIAction(interface: .styledText(cancelLabel, .cancel), action: {})
        let totalActions = [cancelAction] + actions
        showAlert(title, message: message, actions: totalActions, completion: completion)
    }

    func showAlertWithTitle(_ title: String?, text: String, alertType: AlertType,
                            buttonsLayout: AlertButtonsLayout = .horizontal, actions: [UIAction]?) {
        guard let alert = LGAlertViewController(title: title, text: text, alertType: alertType,
                                                buttonsLayout: buttonsLayout, actions: actions) else { return }
        let presenter: UIViewController = tabBarController ?? navigationController ?? self
        presenter.present(alert, animated: true, completion: nil)
    }

    func showActionSheet(_ cancelAction: UIAction, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil,
                         completion: (() -> Void)? = nil) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: barButtonItem, sourceView: nil, sourceRect: nil,
                        completion: completion)
    }
    
    func showActionSheet(_ cancelAction: UIAction, actions: [UIAction], sourceView: UIView? = nil,
                         sourceRect: CGRect? = nil, completion: (() -> Void)? = nil) {
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, sourceView: sourceView,
                        sourceRect: sourceRect, completion: completion)
    }

    func showActionSheet(_ cancelLabel: String, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil) {
        let cancelAction = UIAction(interface: .text(cancelLabel), action: {})
        showActionSheet(cancelAction, actions: actions, barButtonItem: barButtonItem, sourceView: nil,
                        sourceRect: nil, completion: nil)
    }
    
    func showActionSheet(_ cancelLabel: String, actions: [UIAction], sourceView: UIView? = nil,
                         sourceRect: CGRect? = nil) {
        let cancelAction = UIAction(interface: .text(cancelLabel), action: {})
        showActionSheet(cancelAction, actions: actions, barButtonItem: nil, sourceView: sourceView,
                        sourceRect: sourceRect, completion: nil)
    }
    
    private func showActionSheet(_ cancelAction: UIAction, actions: [UIAction], barButtonItem: UIBarButtonItem? = nil,
                                 sourceView: UIView? = nil, sourceRect: CGRect? = nil,
                                 completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let item = barButtonItem {
            alert.popoverPresentationController?.barButtonItem = item
        } else if let sourceView = sourceView, let sourceRect = sourceRect {
            alert.popoverPresentationController?.sourceRect = sourceRect
            alert.popoverPresentationController?.sourceView = sourceView
        } else if DeviceFamily.isiPad {
            showAlert(nil, message: nil, cancelLabel: LGLocalizedString.commonCancel, actions: actions, completion: completion)
            return
        }
        
        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }
            let action = UIAlertAction(title: title, style: .default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: cancelAction.text, style: .cancel, handler: { _ in
            cancelAction.action()
        })
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: completion)
    }
}
