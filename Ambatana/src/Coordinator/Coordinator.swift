//
//  Coordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var children: [Coordinator] { get set }
    var viewController: UIViewController { get }
    weak var presentedAlertViewController: UIAlertController? { get set }

    func openChild(coordinator: Coordinator, animated: Bool, completion: (() -> Void)?)
    func closeChild(coordinator: Coordinator, animated: Bool, completion: (() -> Void)?)
}


// MARK: - Children

extension Coordinator {
    func openChild(coordinator: Coordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        children.append(coordinator)
        viewController.presentViewController(coordinator.viewController, animated: animated, completion: completion)
    }
    
    func closeChild(coordinator: Coordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let index = children.indexOf({ $0 === coordinator }) else { return }

        let lastIndex = children.count - 1
        (index...lastIndex).reverse().forEach { i in
            let child = children[i]
            if i == index {
                child.viewController.dismissViewControllerAnimated(animated, completion: completion)
            } else {
                child.viewController.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }
}


// MARK: - Loading

extension Coordinator {
    func openLoading(message message: String? = LGLocalizedString.commonLoading,
                     animated: Bool = true,
                     completion: (() -> Void)? = nil) {
        guard presentedAlertViewController == nil else { return }

        let finalMessage = (message ?? LGLocalizedString.commonLoading) + "\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        presentedAlertViewController = alert
        viewController.presentViewController(alert, animated: animated, completion: completion)
    }

    func closeLoading(animated animated: Bool = true,
                      completion: (() -> Void)? = nil) {
        closePresentedAlertViewController(animated: animated, completion: completion)
    }

    func closeLoading(animated animated: Bool = true,
                      withAutocloseMessage message: String,
                      autocloseMessageCompletion: (() -> Void)? = nil) {
        closeLoading(animated: animated) { [weak self] in
            self?.openAutocloseMessage(animated: animated, message: message, completion: autocloseMessageCompletion)
        }
    }
}


// MARK: - Autoclose message

private let autocloseMessageDefaultTime: Double = 2.5

extension Coordinator {
    func openAutocloseMessage(animated animated: Bool = true,
                              message: String,
                              time: Double = autocloseMessageDefaultTime,
                              completion: ((Void) -> Void)? = nil) {
        guard presentedAlertViewController == nil else { return }

        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        presentedAlertViewController = alert

        viewController.presentViewController(alert, animated: animated, completion: nil)
        delay(time) { [weak self] in
            self?.closePresentedAlertViewController(animated: animated, completion: completion)
        }
    }
}


// MARK: - Alerts w UIAction

extension Coordinator {
    func openAlert(title: String?, message: String?, actions: [UIAction], completion: (() -> Void)? = nil)
}

//extension UIViewController {
//
//    func showAlert(title: String?, message: String?, actions: [UIAction], completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//
//        actions.forEach { uiAction in
//            guard let title = uiAction.text else { return }
//
//            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
//                uiAction.action()
//            })
//            alert.addAction(action)
//        }
//
//        presentViewController(alert, animated: true, completion: completion)
//    }
//
//    func showAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
//        let cancelAction = UIAction(interface: .StyledText(cancelLabel, .Cancel), action: {})
//        let totalActions = [cancelAction] + actions
//        showAlert(title, message: message, actions: totalActions)
//    }
//
//
//    func showActionSheet(cancelAction: UIAction, actions: [UIAction], completion: (() -> Void)? = nil) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//
//        actions.forEach { uiAction in
//            guard let title = uiAction.text else { return }
//            let action = UIAlertAction(title: title, style: .Default, handler: { _ in
//                uiAction.action()
//            })
//            alert.addAction(action)
//        }
//
//        let cancelAction = UIAlertAction(title: cancelAction.text, style: .Cancel, handler: { _ in
//            cancelAction.action()
//        })
//        alert.addAction(cancelAction)
//
//        presentViewController(alert, animated: true, completion: completion)
//    }
//
//    func showActionSheet(cancelLabel: String, actions: [UIAction]) {
//        let cancelAction = UIAction(interface: .Text(cancelLabel), action: {})
//        showActionSheet(cancelAction, actions: actions)
//    }
//}

// MARK: - Private methods

private extension Coordinator {
    func closePresentedAlertViewController(animated animated: Bool = true,
                                                            completion: (() -> Void)? = nil) {
        guard let presentedAlertViewController = presentedAlertViewController else { return }

        presentedAlertViewController.dismissViewControllerAnimated(animated) { [weak self] in
            self?.presentedAlertViewController = nil
            completion?()
        }
    }
}
