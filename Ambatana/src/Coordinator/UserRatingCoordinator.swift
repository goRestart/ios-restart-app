//
//  UserRatingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol UserRatingCoordinatorDelegate: class {
    func userRatingCoordinatorDidCancel()
    func userRatingCoordinatorDidFinish(withRating rating: Int?, ratedUserId: String?)
}

final class UserRatingCoordinator: Coordinator {
    var child: Coordinator?
    let viewController: UIViewController
    weak var coordinatorDelegate: CoordinatorDelegate?
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    private var parentViewController: UIViewController?

    fileprivate let navigationController: UINavigationController
    fileprivate var ratedUserId: String?
    fileprivate let source: RateUserSource

    weak var delegate: UserRatingCoordinatorDelegate?


    // MARK: - Lifecycle

    convenience init(source: RateUserSource,
                     data: RateUserData) {
        self.init(source: source,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
        let vc = buildRateUser(data: data, showSkipButton: false)
        self.ratedUserId = data.userId
        navigationController.viewControllers = [vc]
    }

    convenience init(source: RateUserSource,
                     buyers: [UserListing]) {
        self.init(source: source,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  sessionManager: Core.sessionManager)
        let vc = buildRateBuyers(buyers: buyers)
        navigationController.viewControllers = [vc]
    }

    init(source: RateUserSource, bubbleNotificationManager: BubbleNotificationManager, sessionManager: SessionManager) {
        self.source = source
        self.bubbleNotificationManager = bubbleNotificationManager
        self.sessionManager = sessionManager
        navigationController = UINavigationController()
        self.viewController = navigationController
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

    fileprivate func buildRateUser(data: RateUserData, showSkipButton: Bool) -> RateUserViewController {
        let userRatingVM = RateUserViewModel(source: source, data: data)
        let userRatingVC = RateUserViewController(viewModel: userRatingVM, showSkipButton: showSkipButton)
        userRatingVM.navigator = self
        return userRatingVC
    }

    fileprivate func buildRateBuyers(buyers: [UserListing]) -> RateBuyersViewController {
        let rateBuyersVM = RateBuyersViewModel(buyers: buyers)
        let rateBuyersVC = RateBuyersViewController(with: rateBuyersVM)
        rateBuyersVM.navigator = self
        return rateBuyersVC
    }
}

// MARK: - RateBuyersNavigator

extension UserRatingCoordinator: RateBuyersNavigator {
    func rateBuyersCancel() {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidCancel()
        }
    }

    func rateBuyersFinish(withUser user: UserListing) {
        guard let data = RateUserData(user: user) else {
            rateBuyersFinishNotOnLetgo()
            return
        }
        self.ratedUserId = data.userId
        let vc = buildRateUser(data: data, showSkipButton: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: nil, ratedUserId: nil)
        }
    }
}


// MARK: - UserRatingNavigator

extension UserRatingCoordinator: RateUserNavigator {
    func rateUserCancel() {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidCancel()
        }
    }

    func rateUserSkip() {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: nil, ratedUserId: self?.ratedUserId)
        }
    }

    func rateUserFinish(withRating rating: Int) {
        closeCoordinator(animated: true) { [weak self] in
            self?.delegate?.userRatingCoordinatorDidFinish(withRating: rating, ratedUserId: self?.ratedUserId)
        }
    }
}
