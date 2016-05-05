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
    weak var presentedAlertController: UIAlertController? { get set }

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
        let finalMessage = (message ?? LGLocalizedString.commonLoading) + "\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .Alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.center = CGPointMake(130.5, 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        openAlertController(alert, animated: animated, completion: completion)
    }

    func closeLoading(animated animated: Bool = true,
                      completion: (() -> Void)? = nil) {
        closePresentedAlertController(animated: animated, completion: completion)
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
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        openAlertController(alert)
        delay(time) { [weak self] in
            self?.closePresentedAlertController(animated: animated, completion: completion)
        }
    }
}


// MARK: - Alerts w UIAction

extension Coordinator {
    func openAlert(animated animated: Bool = true, title: String?, message: String?,
                            actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }

            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }
        openAlertController(alert)
    }

    func openAlert(animated animated: Bool = true, title: String?, message: String?,
                            cancelLabel: String, actions: [UIAction], completion: (() -> Void)? = nil) {
        let cancelAction = UIAction(interface: .StyledText(cancelLabel, .Cancel), action: {})
        let actualActions = [cancelAction] + actions
        openAlert(animated: animated, title: title, message: message, actions: actualActions, completion: completion)
    }

    func openActionSheet(animated animated: Bool = true, title: String?, message: String?,
                                  actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }
            let action = UIAlertAction(title: title, style: .Default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }
        openAlertController(alert)
    }

    func openActionSheet(animated animated: Bool = true, title: String?, message: String?,
                                  cancelLabel: String, actions: [UIAction], completion: (() -> Void)? = nil) {
        let cancelAction = UIAction(interface: .StyledText(cancelLabel, .Cancel), action: {})
        let actualActions = [cancelAction] + actions
        openActionSheet(animated: animated, title: title, message: message, actions: actualActions,
                        completion: completion)
    }
}


// MARK: - Private methods

private extension Coordinator {
    func openAlertController(alert: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard presentedAlertController == nil else { return }

        presentedAlertController = alert
        viewController.presentViewController(alert, animated: animated, completion: completion)
    }

    func closePresentedAlertController(animated animated: Bool = true,
                                                completion: (() -> Void)? = nil) {
        guard let presentedAlertController = presentedAlertController else { return }

        presentedAlertController.dismissViewControllerAnimated(animated) { [weak self] in
            self?.presentedAlertController = nil
            completion?()
        }
    }
}
