//
//  Coordinator.swift
//  LetGo
//
//  Created by AHL on 20/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

public protocol CoordinatorDelegate: class {
    func coordinatorDidClose(_ coordinator: Coordinator)
}

public protocol Coordinator: CoordinatorDelegate {

    /// Possible child coordinator. Will be automatically set on `openChild` method
    var child: Coordinator? { get set }
    /// Delegate for parent coordinators, to notify when this has finished. Will be automatically set on `openChild` method
    weak var coordinatorDelegate: CoordinatorDelegate? { get set }
    /// main view controller
    var viewController: UIViewController { get }
    /// Possible presented alert controller
    weak var presentedAlertController: UIAlertController? { get set }

    /// required to show bubble notification from any coordinator
    var bubbleNotificationManager: BubbleNotificationManager { get }
    /// required to check session and open login if needed
    var sessionManager: SessionManager { get }


    /**
    Once a coordinator is created this method will be called to present/show the main viewController. Each
    implementation is responsible to do so.

    - Parameters:
        - parent: parent view controller, can be used to present the new controller.
        - animated: whether or not the action to present/show should be animated
        - completion: completion closure
    */
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?)


    /** 
    Method that will remove/dismiss the main view controller. It should ALWAYS call completion block, even if
    viewController isn't presented or is already dismissed. When a coordinator is closed it will call this method
    during the process.
    - Parameters:
       - animated: whether or not the action should be animated
       - completion: completion closure
    */
    func dismissViewController(animated: Bool, completion: (() -> Void)?)
}


// MARK: - CoordinatorDelegate

extension Coordinator {
    public func coordinatorDidClose(_ coordinator: Coordinator) {
        child = nil
    }
}


// MARK: - Helpers

extension Coordinator {
    func openChild(coordinator: Coordinator, parent: UIViewController, animated: Bool, forceCloseChild: Bool,
                         completion: (() -> Void)?) {
        let presentBlock = {
            self.child?.coordinatorDelegate = nil
            self.child = coordinator
            coordinator.coordinatorDelegate = self
            coordinator.presentViewController(parent: parent, animated: animated, completion: completion)
        }

        if let child = child {
            let message: String
            if forceCloseChild {
                child.closeCoordinator(animated: false, completion: presentBlock)
                message = "\(type(of:self)) is opening \(type(of:coordinator.self)) while child \(type(of:child.self)) was present"
            } else {
                message = "\(type(of:self)) couldn't open \(type(of:coordinator.self)) because child \(type(of:child.self)) was present"
            }
            logMessage(.error, type: [.navigation], message: message)
            report(AppReport.navigation(error: .childCoordinatorPresent), message: message)
        } else {
            presentBlock()
        }
    }

    func closeCoordinator(animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.dismissViewController(animated: animated) {
                guard let strongSelf = self else { return }
                strongSelf.coordinatorDelegate?.coordinatorDidClose(strongSelf)
                completion?()
            }
        }

        if let child = child {
            child.closeCoordinator(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }
}


// TODO: To be moved to the corresponding component when it is created
//// MARK: - Login
//
//extension Coordinator {
//    func openLoginIfNeeded(from source: EventParameterLoginSourceValue, style: LoginStyle,
//                           loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
//        guard !sessionManager.loggedIn else {
//            loggedInAction()
//            return
//        }
//        let coordinator = LoginCoordinator(source: source,
//                                           style: style,
//                                           loggedInAction: loggedInAction,
//                                           cancelAction: cancelAction)
//        openChild(coordinator: coordinator,
//                  parent: viewController,
//                  animated: true,
//                  forceCloseChild: true,
//                  completion: nil)
//    }
//}


// MARK: - Alerts

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

    // MARK: > Action sheet
    
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
    
    // MARK: > Autoclousure message
    
    func openAutocloseMessage(animated: Bool = true,
                              message: String,
                              time: TimeInterval = SharedConstants.autocloseMessageDefaultTime,
                              completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        openAlertController(alert)
        delay(time) { [weak self] in
            self?.closePresentedAlertController(animated: animated, completion: completion)
        }
    }
    
    // MARK: > Loading indicators
    
    func openLoading(message: String? = R.Strings.commonLoading,
                     animated: Bool = true,
                     completion: (() -> Void)? = nil) {
        let finalMessage = (message ?? R.Strings.commonLoading) + "\n\n\n"
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
    
    // MARK: > Bubble
    
    func showBubble(with data: BubbleNotificationData, duration: TimeInterval) {
        bubbleNotificationManager.showBubble(data, duration: duration, view: viewController.view)
    }
    
    // MARK: > Helpers
    
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
