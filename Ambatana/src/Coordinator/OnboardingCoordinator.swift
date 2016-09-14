//
//  OnboardingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol OnboardingCoordinatorDelegate: CoordinatorDelegate {
    func onboardingCoordinator(coordinator: OnboardingCoordinator, didFinishPosting posting: Bool)
}

class OnboardingCoordinator: Coordinator {

    weak var delegate: OnboardingCoordinatorDelegate?

    var child: Coordinator?

    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    private let locationManager: LocationManager
    private var presentedViewControllers: [UIViewController] = []

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance, locationManager: Core.locationManager)
    }

    init(keyValueStorage: KeyValueStorage, locationManager: LocationManager) {
        self.locationManager = locationManager
        let signUpVM = SignUpViewModel(appearance: .Dark, source: .Install)
        let tourVM = TourLoginViewModel()
        viewController = TourLoginViewController(signUpViewModel: signUpVM, tourLoginViewModel: tourVM, completion: nil)

        tourVM.navigator = self
    }

    func open(parent parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parentViewController == nil else { return }
        parent.presentViewController(viewController, animated: animated, completion: completion)
    }

    func close(animated animated: Bool, completion: (() -> Void)?) {
        recursiveClose(animated: animated, completion: completion)
    }

    private func recursiveClose(animated animated: Bool, completion: (() -> Void)?) {
        if let vc = presentedViewControllers.last {
            presentedViewControllers.removeLast()
            vc.dismissViewControllerAnimated(animated) { [weak self] in
                self?.recursiveClose(animated: false, completion: completion)
            }
        } else {
            viewController.dismissViewControllerAnimated(animated, completion: completion)
        }
    }

    func finish(withPosting posting: Bool) {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
            strongSelf.delegate?.onboardingCoordinator(strongSelf, didFinishPosting: posting)
        }
    }

    private func hideVC(viewController: UIViewController) {
        UIView.animateWithDuration(0.3, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            viewController.view.alpha = 0
        }, completion: nil)
    }

    private func topViewController() -> UIViewController {
        return presentedViewControllers.last ?? viewController
    }

    private func openTourNotifications() {
        let topVC = topViewController()
        let type: PrePermissionType = .Onboarding
        let vm = TourNotificationsViewModel(title: type.title, subtitle: type.subtitle, pushText: type.pushMessage,
                                            source: type)
        vm.navigator = self
        let vc = TourNotificationsViewController(viewModel: vm)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.presentViewController(vc, animated: true, completion: nil)
    }

    private func openTourLocation() {
        let topVC = topViewController()
        let vm = TourLocationViewModel(source: .Install)
        vm.navigator = self
        let vc = TourLocationViewController(viewModel: vm)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.presentViewController(vc, animated: true, completion: nil)
    }

    private func openTourPosting() {
        let topVC = topViewController()
        let vm = TourPostingViewModel()
        vm.navigator = self
        let vc = TourPostingViewController(viewModel: vm, completion: nil)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.presentViewController(vc, animated: true, completion: nil)
    }
}


extension OnboardingCoordinator: TourLoginNavigator {
    func tourLoginFinish() {
        let casnAskForPushPermissions = PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.Onboarding)

        if casnAskForPushPermissions {
            openTourNotifications()
        } else if Core.locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else if FeatureFlags.incentivizePostingMode != .Original {
            openTourPosting()
        } else {
            finish(withPosting: false)
        }
    }
}


extension OnboardingCoordinator: TourNotificationsNavigator {
    func tourNotificationsFinish() {
        if Core.locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else if FeatureFlags.incentivizePostingMode != .Original {
            openTourPosting()
        } else {
            finish(withPosting: false)
        }
    }
}

extension OnboardingCoordinator: TourLocationNavigator {
    func tourLocationFinish() {
        if FeatureFlags.incentivizePostingMode != .Original {
            openTourPosting()
        } else {
            finish(withPosting: false)
        }
    }
}


extension OnboardingCoordinator: TourPostingNavigator {
    func tourPostingClose() {
        finish(withPosting: false)
    }

    func tourPostingPost() {
        finish(withPosting: true)
    }
}
