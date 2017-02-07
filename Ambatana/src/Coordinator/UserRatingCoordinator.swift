//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserRatingCoordinatorDelegate: CoordinatorDelegate {
    func userRatingCoordinatorDidCancel()
    func userRatingCoordinatorDidFinish(withRating rating: Int?, ratedUserId: String?)
}

final class UserRatingCoordinator: Coordinator {
    var child: Coordinator?

    private var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    fileprivate let navigationController: UINavigationController
    fileprivate var ratedUserId: String?

    weak var delegate: UserRatingCoordinatorDelegate?


    // MARK: - Lifecycle

    convenience init(source: RateUserSource, data: RateUserData) {
        self.init()
        let vc = buildRateUser(source: source, data: data, showSkipButton: false)
        self.ratedUserId = data.userId
        navigationController.viewControllers = [vc]
    }

    convenience init(buyers: [UserProduct]) {
        self.init()
        let vc = buildRateBuyers(buyers: buyers)
        navigationController.viewControllers = [vc]
    }

    init() {
        navigationController = UINavigationController()
        self.viewController = navigationController
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            self?.viewController.dismiss(animated: animated) { [weak self] in
                guard let strongSelf = self else { return }
                completion?()
                strongSelf.delegate?.coordinatorDidClose(strongSelf)

            }
        }

        if let child = child {
            child.close(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }


    // MARK: - Private

    fileprivate func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> RateUserViewController {
        let userRatingVM = RateUserViewModel(source: source, data: data)
        let userRatingVC = RateUserViewController(viewModel: userRatingVM, showSkipButton: showSkipButton)
        userRatingVM.navigator = self
        return userRatingVC
    }

    fileprivate func buildRateBuyers(buyers: [UserProduct]) -> RateBuyersViewController {
        let rateBuyersVM = RateBuyersViewModel(buyers: buyers)
        let rateBuyersVC = RateBuyersViewController(with: rateBuyersVM)
        rateBuyersVM.navigator = self
        return rateBuyersVC
    }
}

// MARK: - RateBuyersNavigator

extension UserRatingCoordinator: RateBuyersNavigator {
    func rateBuyersCancel() {
        close(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidCancel()
        }
    }

    func rateBuyersFinish(withUser user: UserProduct) {
        guard let data = RateUserData(user: user) else {
            rateBuyersFinishNotOnLetgo()
            return
        }
        self.ratedUserId = data.userId
        let vc = buildRateUser(source: .markAsSold, data: data, showSkipButton: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        close(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: nil, ratedUserId: nil)
        }
    }
}


// MARK: - UserRatingNavigator

extension UserRatingCoordinator: RateUserNavigator {
    func rateUserCancel() {
        close(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidCancel()
        }
    }

    func rateUserSkip() {
        close(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: nil, ratedUserId: self?.ratedUserId)
        }
    }

    func rateUserFinish(withRating rating: Int) {
        close(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: rating, ratedUserId: self?.ratedUserId)
        }
    }
}
