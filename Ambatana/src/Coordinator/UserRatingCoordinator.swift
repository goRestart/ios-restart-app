//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol UserRatingCoordinatorDelegate: CoordinatorDelegate {
    func userRatingCoordinatorDidCancel(coordinator: UserRatingCoordinator)
    func userRatingCoordinatorDidFinish(coordinator: UserRatingCoordinator, withRating rating: Int?)
}

final class UserRatingCoordinator: Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    weak var delegate: UserRatingCoordinatorDelegate?


    // MARK: - Lifecycle

    init(source: RateUserSource, data: RateUserData) {
        let userRatingVM = RateUserViewModel(source: source, data: data)
        let userRatingVC = RateUserViewController(viewModel: userRatingVM)
        let navC = UINavigationController(rootViewController: userRatingVC)
        navC.modalPresentationStyle = .OverCurrentContext
        self.viewController = navC

        userRatingVM.navigator = self
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parentViewController == nil else { return }

        parentViewController = parent
        parent.presentViewController(viewController, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        close(animated: animated, rating: nil, completion: completion)
    }


    // MARK: - Private

    private func close(animated animated: Bool, rating: Int?, completion: (() -> Void)?) {
        let finished = rating == nil
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismissViewControllerAnimated(animated) { [weak self] in
                guard let strongSelf = self else { return }
                finished ? strongSelf.delegate?.userRatingCoordinatorDidFinish(strongSelf, withRating: rating) :
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
        close(animated: true, rating: nil, completion: nil)
    }

    func rateUserFinish(withRating rating: Int) {
        close(animated: true, rating: rating, completion: nil)
    }
}
