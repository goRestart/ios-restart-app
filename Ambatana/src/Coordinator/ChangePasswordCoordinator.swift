//
//  ChangePasswordCoordinator.swift
//  LetGo
//
//  Created by Juan Iglesias on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

final class ChangePasswordCoordinator: Coordinator {
    var child: Coordinator?
    
    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?
    
    weak var delegate: CoordinatorDelegate?
    
    
    // MARK: - Lifecycle
    
    init(token: String) {
        let changePasswordVM = ChangePasswordViewModel(token: token)
        let changePasswordVC = ChangePasswordViewController(viewModel: changePasswordVM)
        let navC = UINavigationController(rootViewController: changePasswordVC)
        navC.modalPresentationStyle = .OverCurrentContext
        self.viewController = navC
        
        changePasswordVM.navigator = self
    }
    
    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parentViewController == nil else { return }
        
        parentViewController = parent
        parent.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func close(animated animated: Bool, completion: (() -> Void)?) {
        closeChangePassword(animated: animated, completion: completion)
    }
    
    
    // MARK: - Private
    
    private func closeChangePassword(animated animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismissViewControllerAnimated(animated) { [weak self] in
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
