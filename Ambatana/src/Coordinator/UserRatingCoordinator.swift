//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserRatingCoordinatorDelegate: CoordinatorDelegate {
    func userRatingCoordinatorDidCancel(coordinator: UserRatingCoordinator)
    func userRatingCoordinatorDidFinish(coordinator: UserRatingCoordinator)
}

final class UserRatingCoordinator: Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    weak var delegate: UserRatingCoordinatorDelegate?


    // MARK: - Lifecycle

    convenience init?(user: User) {
        guard let userId = user.objectId else { return nil }
        self.init(userId: userId, userAvatar: user.avatar?.fileURL, userName: user.name)
    }

    convenience init?(user: ChatInterlocutor) {
        guard let userId = user.objectId else { return nil }
        self.init(userId: userId, userAvatar: user.avatar?.fileURL, userName: user.name)
    }

    init(userId: String, userAvatar: NSURL?, userName: String?) {
        let userRatingVM = RateUserViewModel(userId: userId, userAvatar: userAvatar, userName: userName)
        self.viewController = RateUserViewController(viewModel: userRatingVM)
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let userRatingVC = viewController as? RateUserViewController else { return }
        guard userRatingVC.parentViewController == nil else { return }

        parentViewController = parent
        parent.presentViewController(userRatingVC, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(finished: false, animated: animated, completion: completion)
    }


    // MARK: - Private

    private func close(finished finished: Bool, animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismissViewControllerAnimated(animated) { [weak self] in
                guard let strongSelf = self else { return }
                finished ? strongSelf.delegate?.userRatingCoordinatorDidFinish(strongSelf) :
                            strongSelf.delegate?.userRatingCoordinatorDidCancel(strongSelf)
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

extension UserRatingCoordinator: RateUserNavigator {
    func rateUserCancel() {
        close(finished: false, animated: true, completion: nil)
    }

    func rateUserFinish() {
        close(finished: true, animated: true, completion: nil)
    }
}
