//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 28/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PassiveBuyersCoordinatorDelegate: class {
    func passiveBuyersCoordinatorDidCancel(_ coordinator: PassiveBuyersCoordinator)
    func passiveBuyersCoordinatorDidFinish(_ coordinator: PassiveBuyersCoordinator)
}

final class PassiveBuyersCoordinator: Coordinator {
    var child: Coordinator?
    var viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    private var parentViewController: UIViewController?

    weak var delegate: PassiveBuyersCoordinatorDelegate?


    // MARK: - Lifecycle

    convenience init(passiveBuyersInfo: PassiveBuyersInfo) {
        self.init(passiveBuyersInfo: passiveBuyersInfo,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(passiveBuyersInfo: PassiveBuyersInfo,
         bubbleNotificationManager: BubbleNotificationManager,
         sessionManager: SessionManager) {
        let passiveBuyersVM = PassiveBuyersViewModel(passiveBuyers: passiveBuyersInfo)
        let passiveBuyersVC = PassiveBuyersViewController(viewModel: passiveBuyersVM)
        self.viewController = passiveBuyersVC
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        passiveBuyersVM.navigator = self
    }

    func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }

    func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }


    // MARK: - Private

    fileprivate func close(animated: Bool, completed: Bool) {
        closeCoordinator(animated: animated) { [weak self] in
            guard let strongSelf = self else { return }
            completed ? strongSelf.delegate?.passiveBuyersCoordinatorDidFinish(strongSelf) :
                strongSelf.delegate?.passiveBuyersCoordinatorDidCancel(strongSelf)
        }
    }
}


// MARK: - PassiveBuyersNavigator

extension PassiveBuyersCoordinator: PassiveBuyersNavigator {
    func passiveBuyersCancel() {
        close(animated: true, completed: false)
    }

    func passiveBuyersCompleted() {
        close(animated: true, completed: true)
    }
}
