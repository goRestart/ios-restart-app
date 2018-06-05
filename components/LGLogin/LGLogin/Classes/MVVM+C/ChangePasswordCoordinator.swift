//
//  ChangePasswordCoordinator.swift
//  LetGo
//
//  Created by Juan Iglesias on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol ChangePasswordPresenter {
    func openChangePassword(coordinator: ChangePasswordCoordinator)
}

final class ChangePasswordCoordinator: Coordinator {
    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager
    
    
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

    
    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}


// MARK: - ChangePasswordNavigator

extension ChangePasswordCoordinator: ChangePasswordNavigator {
    func closeChangePassword() {
        closeCoordinator(animated: true, completion: nil)
    }
}
