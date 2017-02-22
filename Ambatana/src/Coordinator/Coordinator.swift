//
//  Coordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol CoordinatorDelegate: class {
    func coordinatorDidClose(_ coordinator: Coordinator)
}

protocol Coordinator: CoordinatorDelegate {
    var child: Coordinator? { get set }
    var viewController: UIViewController { get }
    weak var presentedAlertController: UIAlertController? { get set }
    var bubbleNotificationManager: BubbleNotificationManager { get }
    var sessionManager: SessionManager { get }
    
    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?)
    func close(animated: Bool, completion: (() -> Void)?)
}


// MARK: - Bubble

extension Coordinator {
    // TODO: using window not viewcontroller
    func showBubble(with data: BubbleNotificationData, duration: TimeInterval) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let window = appDelegate.window else { return }
        bubbleNotificationManager.showBubble(data, duration: duration, view: window)
    }
}


// MARK: - CoordinatorDelegate

extension Coordinator {
    func coordinatorDidClose(_ coordinator: Coordinator) {
        child = nil
    }
}


// MARK: - Helpers

extension Coordinator {
    func openCoordinator(coordinator: Coordinator, parent: UIViewController, animated: Bool,
                         completion: (() -> Void)?) {
        guard child == nil else { return }
        child = coordinator
        coordinator.open(parent: parent, animated: animated, completion: completion)
    }
}


// MARK: - Login

extension Coordinator {
    func openLoginIfNeeded(from source: EventParameterLoginSourceValue, style: LoginStyle,
                           loggedInAction: @escaping (() -> Void), delegate: LoginCoordinatorDelegate?) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }
        let coordinator = LoginCoordinator(source: source, style: style, loggedInAction: loggedInAction)
        coordinator.delegate = delegate
        openCoordinator(coordinator: coordinator, parent: viewController, animated: true, completion: nil)
    }
}


// MARK: - Loading

extension Coordinator {
    func openLoading(message: String? = LGLocalizedString.commonLoading,
                     animated: Bool = true,
                     completion: (() -> Void)? = nil) {
        let finalMessage = (message ?? LGLocalizedString.commonLoading) + "\n\n\n"
        let alert = UIAlertController(title: finalMessage, message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.color = UIColor.black
        activityIndicator.center = CGPoint(x: 130.5, y: 85.5)
        alert.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        openAlertController(alert, animated: animated, completion: completion)
    }

    func closeLoading(animated: Bool = true,
                      completion: (() -> Void)? = nil) {
        closePresentedAlertController(animated: animated, completion: completion)
    }

    func closeLoading(animated: Bool = true,
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
    func openAutocloseMessage(animated: Bool = true,
                              message: String,
                              time: Double = autocloseMessageDefaultTime,
                              completion: ((Void) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        openAlertController(alert)
        delay(time) { [weak self] in
            self?.closePresentedAlertController(animated: animated, completion: completion)
        }
    }
}


// MARK: - Alerts w UIAction

extension Coordinator {
    func openAlert(animated: Bool = true, title: String?, message: String?,
                            actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }

            let action = UIAlertAction(title: title, style: uiAction.style.alertActionStyle, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }
        openAlertController(alert)
    }

    func openAlert(animated: Bool = true, title: String?, message: String?,
                            cancelLabel: String, actions: [UIAction], completion: (() -> Void)? = nil) {
        let cancelAction = UIAction(interface: .styledText(cancelLabel, .cancel), action: {})
        let actualActions = [cancelAction] + actions
        openAlert(animated: animated, title: title, message: message, actions: actualActions, completion: completion)
    }

    func openActionSheet(animated: Bool = true, title: String?, message: String?,
                                  actions: [UIAction], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach { uiAction in
            guard let title = uiAction.text else { return }
            let action = UIAlertAction(title: title, style: .default, handler: { _ in
                uiAction.action()
            })
            alert.addAction(action)
        }
        openAlertController(alert)
    }

    func openActionSheet(animated: Bool = true, title: String?, message: String?,
                                  cancelLabel: String, actions: [UIAction], completion: (() -> Void)? = nil) {
        let cancelAction = UIAction(interface: .styledText(cancelLabel, .cancel), action: {})
        let actualActions = [cancelAction] + actions
        openActionSheet(animated: animated, title: title, message: message, actions: actualActions,
                        completion: completion)
    }
}


// MARK: - Private methods

fileprivate extension Coordinator {
    func openAlertController(_ alert: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard presentedAlertController == nil else { return }

        presentedAlertController = alert
        viewController.present(alert, animated: animated, completion: completion)
    }

    func closePresentedAlertController(animated: Bool = true,
                                                completion: (() -> Void)? = nil) {
        guard let presentedAlertController = presentedAlertController else { return }

        presentedAlertController.dismiss(animated: animated) { [weak self] in
            self?.presentedAlertController = nil
            completion?()
        }
    }
}
