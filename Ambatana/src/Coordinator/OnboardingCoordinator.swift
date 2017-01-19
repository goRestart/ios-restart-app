//
//  OnboardingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol OnboardingCoordinatorDelegate: CoordinatorDelegate {
    func onboardingCoordinator(_ coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?)
}

class OnboardingCoordinator: Coordinator {

    weak var delegate: OnboardingCoordinatorDelegate?

    var child: Coordinator?

    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

    fileprivate let locationManager: LocationManager
    private var presentedViewControllers: [UIViewController] = []
    
    private let featureFlags: FeatureFlaggeable

    convenience init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance, locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(keyValueStorage: KeyValueStorage, locationManager: LocationManager, featureFlags: FeatureFlaggeable) {
        self.locationManager = locationManager
        self.featureFlags = featureFlags

        viewController = TourBlurBackgroundViewController()
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: false) { [weak self] in
            guard let strongSelf = self else { return }
            let signUpVM = SignUpViewModel(appearance: .dark, source: .install)
            let tourVM = TourLoginViewModel(signUpViewModel: signUpVM)
            tourVM.navigator = strongSelf
            let tourVC = TourLoginViewController(viewModel: tourVM)
            strongSelf.presentedViewControllers.append(tourVC)
            strongSelf.viewController.present(tourVC, animated: true, completion: completion)
        }
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        recursiveClose(animated: animated, completion: completion)
    }

    private func recursiveClose(animated: Bool, completion: (() -> Void)?) {
        if let vc = presentedViewControllers.last {
            presentedViewControllers.removeLast()
            vc.dismiss(animated: false) { [weak self] in
                self?.recursiveClose(animated: false, completion: completion)
            }
        } else {
            viewController.dismiss(animated: animated, completion: completion)
        }
    }

    func finish(withPosting posting: Bool, source: PostingSource?) {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
            strongSelf.delegate?.onboardingCoordinator(strongSelf, didFinishPosting: posting, source: source)
        }
    }

    private func hideVC(_ viewController: UIViewController) {
        UIView.animate(withDuration: 0.3, animations: {
            viewController.view.alpha = 0
        }) 
    }

    fileprivate func topViewController() -> UIViewController {
        return presentedViewControllers.last ?? viewController
    }

    fileprivate func openTourNotifications() {
        let topVC = topViewController()
        let type: PrePermissionType = .onboarding
        let vm = TourNotificationsViewModel(title: type.title, subtitle: type.subtitle, pushText: type.pushMessage,
                                            source: type)
        vm.navigator = self
        let vc = TourNotificationsViewController(viewModel: vm)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }

    fileprivate func openTourLocation() {
        let topVC = topViewController()
        let vm = TourLocationViewModel(source: .install)
        vm.navigator = self
        let vc = TourLocationViewController(viewModel: vm)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }

    fileprivate func openTourPosting() {
        let topVC = topViewController()
        let vm = TourPostingViewModel()
        vm.navigator = self
        let vc = TourPostingViewController(viewModel: vm)
        hideVC(topVC)
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }
}


extension OnboardingCoordinator: TourLoginNavigator {
    func tourLoginFinish() {
        let casnAskForPushPermissions = PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.onboarding)

        if casnAskForPushPermissions {
            openTourNotifications()
        } else if locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }

    func tourLoginOpenLoginSignup(signupLoginVM: SignUpLogInViewModel, afterLoginCompletion: (() -> Void)?) {
        let topVC = topViewController()
        let vc = SignUpLogInViewController(viewModel: signupLoginVM, appearance: .dark, keyboardFocus: true)
        vc.afterLoginAction = afterLoginCompletion
        let nav = UINavigationController(rootViewController: vc)
        topVC.present(nav, animated: true, completion: nil)
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

    func tourPostingPost(fromCamera: Bool) {
        finish(withPosting: true, source: fromCamera ? .onboardingCamera : .onboardingButton)
    }
}
