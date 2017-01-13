//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 28/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PassiveBuyersCoordinatorDelegate: CoordinatorDelegate {
    func passiveBuyersCoordinatorDidCancel(_ coordinator: PassiveBuyersCoordinator)
    func passiveBuyersCoordinatorDidFinish(_ coordinator: PassiveBuyersCoordinator)
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

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        close(animated: animated, completed: false, completion: completion)
    }


    // MARK: - Private

    fileprivate func close(animated: Bool, completed: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismiss(animated: animated) { [weak self] in
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
