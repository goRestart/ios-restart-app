//
//  ChangePasswordCoordinator.swift
//  LetGo
//
//  Created by Juan Iglesias on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class ChangePasswordCoordinator: Coordinator {
    var child: Coordinator?
    let viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    private var parentViewController: UIViewController?

    weak var delegate: CoordinatorDelegate?
    
    
    // MARK: - Lifecycle

    convenience init(token: String) {
        self.init(token: token,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(token: String,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        let changePasswordVM = ChangePasswordViewModel(token: token)
        let changePasswordVC = ChangePasswordViewController(viewModel: changePasswordVM)
        let navC = UINavigationController(rootViewController: changePasswordVC)
        navC.modalPresentationStyle = .overCurrentContext
        self.viewController = navC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        changePasswordVM.navigator = self
    }

    
    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        
        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }
    
    func close(animated: Bool, completion: (() -> Void)?) {
        closeChangePassword(animated: animated, completion: completion)
    }
    
    
    // MARK: - Private
    
    private func closeChangePassword(animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismiss(animated: animated) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.coordinatorDidClose(strongSelf)
                completion?()
            }
        }
        
        if let child = child {
            child.close(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }
}


// MARK: - ChangePasswordNavigator

extension ChangePasswordCoordinator: ChangePasswordNavigator {
    func closeChangePassword() {
        close(animated: true, completion: nil)
    }
}
