//
//  UserPhoneVerificationCoordinator.swift
//  LetGo
//
//  Created by Sergi Gracia on 05/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

final class UserPhoneVerificationCoordinator: Coordinator {

    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    init(bubbleNotificationManager: BubbleNotificationManager = LGBubbleNotificationManager.sharedInstance,
         sessionManager: SessionManager = Core.sessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager

        let viewModel = UserPhoneVerificationNumberInputViewModel()
        let viewController = UserPhoneVerificationNumberInputViewController(viewModel: viewModel)
        self.viewController = viewController
        viewModel.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let parentNavigationController = parent as? UINavigationController else { return }
        parentNavigationController.pushViewController(viewController, animated: true)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.popViewController(animated: true)
    }

}

extension UserPhoneVerificationCoordinator: UserPhoneVerificationNavigator {

    func openCountrySelector() {
        let countrySelectorViewModel = UserPhoneVerificationCountryPickerViewModel()
        let countrySelectorViewController = UserPhoneVerificationCountryPickerViewController(viewModel: countrySelectorViewModel)
        viewController.presentViewController(countrySelectorViewController, animated: true, onMainThread: true)
    }

    func openCodeInput() {
        let codeInputViewModel = UserPhoneVerificationCodeInputViewModel()
        let codeInputViewController = UserPhoneVerificationCodeInputViewController(viewModel: codeInputViewModel)
        viewController.pushViewController(codeInputViewController, animated: true)
    }
}
