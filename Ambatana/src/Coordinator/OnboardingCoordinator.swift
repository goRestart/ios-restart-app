//
//  OnboardingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol OnboardingCoordinatorDelegate: CoordinatorDelegate {
    func onboardingCoordinator(coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?)
}

class OnboardingCoordinator: Coordinator {

    weak var delegate: OnboardingCoordinatorDelegate?

    var child: Coordinator?

    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    private let locationManager: LocationManager
    private var presentedViewControllers: [UIViewController] = []
    
    private let featureFlags: FeatureFlags

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance, locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(keyValueStorage: KeyValueStorage, locationManager: LocationManager, featureFlags: FeatureFlags) {
        self.locationManager = locationManager
        self.featureFlags = featureFlags
        let signUpVM = SignUpViewModel(appearance: .Dark, source: .Install)
        let tourVM = TourLoginViewModel()
        viewController = TourLoginViewController(signUpViewModel: signUpVM, tourLoginViewModel: tourVM)

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

    func finish(withPosting posting: Bool, source: PostingSource?) {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
            strongSelf.delegate?.onboardingCoordinator(strongSelf, didFinishPosting: posting, source: source)
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
        if featureFlags.directPostInOnboarding {
            tourPostingPost(fromCamera: true)
        } else {
            let topVC = topViewController()
            let vm = TourPostingViewModel()
            vm.navigator = self
            let vc = TourPostingViewController(viewModel: vm)
            hideVC(topVC)
            presentedViewControllers.append(vc)
            topVC.presentViewController(vc, animated: true, completion: nil)
        }
    }
}


extension OnboardingCoordinator: TourLoginNavigator {
    func tourLoginFinish() {
        let casnAskForPushPermissions = PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.Onboarding)

        if casnAskForPushPermissions {
            openTourNotifications()
        } else if locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }
}


extension OnboardingCoordinator: TourNotificationsNavigator {
    func tourNotificationsFinish() {
        if locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }
}

extension OnboardingCoordinator: TourLocationNavigator {
    func tourLocationFinish() {
        openTourPosting()
    }
}


extension OnboardingCoordinator: TourPostingNavigator {
    func tourPostingClose() {
        finish(withPosting: false, source: nil)
    }

    func tourPostingPost(fromCamera fromCamera: Bool) {
        finish(withPosting: true, source: fromCamera ? .OnboardingCamera : .OnboardingButton)
    }
}
