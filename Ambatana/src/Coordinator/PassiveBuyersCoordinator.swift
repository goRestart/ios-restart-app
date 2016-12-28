//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 28/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PassiveBuyersCoordinatorDelegate: CoordinatorDelegate {
    func passiveBuyersCoordinatorDidCancel(coordinator: PassiveBuyersCoordinator)
    func passiveBuyersCoordinatorDidFinish(coordinator: PassiveBuyersCoordinator)
}

final class PassiveBuyersCoordinator: Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    weak var delegate: PassiveBuyersCoordinatorDelegate?


    // MARK: - Lifecycle

    init(passiveBuyersInfo: PassiveBuyersInfo) {
        let passiveBuyersVM = PassiveBuyersViewModel(passiveBuyers: passiveBuyersInfo)
        let passiveBuyersVC = PassiveBuyersViewController(viewModel: passiveBuyersVM)
        self.viewController = passiveBuyersVC

        passiveBuyersVM.navigator = self
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parentViewController == nil else { return }

        parentViewController = parent
        parent.presentViewController(viewController, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(animated: animated, completed: false, completion: completion)
    }


    // MARK: - Private

    private func close(animated animated: Bool, completed: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismissViewControllerAnimated(animated) { [weak self] in
                guard let strongSelf = self else { return }
                completed ? strongSelf.delegate?.passiveBuyersCoordinatorDidFinish(strongSelf) :
                    strongSelf.delegate?.passiveBuyersCoordinatorDidCancel(strongSelf)
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


// MARK: - UserRatingNavigator

extension PassiveBuyersCoordinator: PassiveBuyersNavigator {
    func passiveBuyersCancel() {
        close(animated: true, completed: false, completion: nil)
    }

    func passiveBuyersCompleted() {
        close(animated: true, completed: true, completion: nil)
    }
}
