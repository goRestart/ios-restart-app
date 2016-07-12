//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

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

    init(userId: String, userAvatar: NSURL?, userName: String?) {

        let userRatingVM = UserRatingViewModel(userId: userId, userAvatar: userAvatar, userName: userName)
        self.viewController = UserRatingViewController(viewModel: userRatingVM)
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let userRatingVC = viewController as? UserRatingViewController else { return }
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
