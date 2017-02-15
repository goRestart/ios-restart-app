//
//  OnboardingCoordinator.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SafariServices

protocol OnboardingCoordinatorDelegate: CoordinatorDelegate {
    func onboardingCoordinator(_ coordinator: OnboardingCoordinator, didFinishPosting posting: Bool, source: PostingSource?)
}

final class OnboardingCoordinator: Coordinator {
    var child: Coordinator?
    let viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager

    weak var delegate: OnboardingCoordinatorDelegate?

    fileprivate let locationManager: LocationManager
    fileprivate var presentedViewControllers: [UIViewController] = []
    
    fileprivate let featureFlags: FeatureFlaggeable

    fileprivate weak var recaptchaTokenDelegate: RecaptchaTokenDelegate?


    // MARK: - Lifecycle


    convenience init() {
        self.init(locationManager: Core.locationManager,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(locationManager: LocationManager,
         bubbleNotificationManager: BubbleNotificationManager,
         featureFlags: FeatureFlaggeable) {
        self.locationManager = locationManager
        self.bubbleNotificationManager = bubbleNotificationManager
        self.featureFlags = featureFlags

        viewController = TourBlurBackgroundViewController()
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: false) { [weak self] in
            guard let strongSelf = self else { return }

            let signUpVM = SignUpViewModel(appearance: .dark,
                                           source: .install)
            signUpVM.navigator = strongSelf
            let tourVM = TourLoginViewModel(signUpViewModel: signUpVM, featureFlags: strongSelf.featureFlags)
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


// MARK: - TourLoginNavigator

extension OnboardingCoordinator: TourLoginNavigator {
    func tourLoginFinish() {
        let pushPermissionsManager = PushPermissionsManager.sharedInstance
        let canAskForPushPermissions = pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.onboarding)

        if canAskForPushPermissions {
            openTourNotifications()
        } else if locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }
}


// MARK: - TourNotificationsNavigator

extension OnboardingCoordinator: TourNotificationsNavigator {
    func tourNotificationsFinish() {
        if locationManager.shouldAskForLocationPermissions() {
            openTourLocation()
        } else {
            openTourPosting()
        }
    }
}


// MARK: - TourLocationNavigator

extension OnboardingCoordinator: TourLocationNavigator {
    func tourLocationFinish() {
        openTourPosting()
    }
}


// MARK: - TourPostingNavigator

extension OnboardingCoordinator: TourPostingNavigator {
    func tourPostingClose() {
        finish(withPosting: false, source: nil)
    }

    func tourPostingPost(fromCamera: Bool) {
        finish(withPosting: true, source: fromCamera ? .onboardingCamera : .onboardingButton)
    }
}


// MARK: - MainSignUpNavigator

extension OnboardingCoordinator: MainSignUpNavigator {
    func cancelMainSignUp() {
        tourLoginFinish()
    }

    func closeMainSignUp(myUser: MyUser) {
        tourLoginFinish()
    }

    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        // scammer alert is ignored in on-boarding
        tourLoginFinish()
    }

    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?) {
        let vc: UIViewController

        switch featureFlags.signUpLoginImprovement {
        case .v1, .v1WImprovements:
            let vm = SignUpLogInViewModel(source: .install, collapsedEmailParam: collapsedEmailParam, action: .signup)
            vm.navigator = self
            vc = SignUpLogInViewController(viewModel: vm,
                                           appearance: .dark,
                                           keyboardFocus: true)
            recaptchaTokenDelegate = vm
        case .v2:
            let vm = SignUpEmailStep1ViewModel(source: .install, collapsedEmail: collapsedEmailParam)
            vm.navigator = self

            vc = SignUpEmailStep1ViewController(viewModel: vm,
                                                appearance: .dark,
                                                backgroundImage: loginV2BackgroundImage)
        }

        let navCtl = UINavigationController(rootViewController: vc)
        navCtl.modalPresentationStyle = .custom
        navCtl.modalTransitionStyle = .crossDissolve

        let topVC = topViewController()
        topVC.present(navCtl, animated: true, completion: nil)
    }

    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?) {
        // log in should not be opened in on-boarding
    }

    func openHelpFromMainSignUp() {
        openHelp()
    }
}


// MARK: - V1
// MARK: - SignUpLogInNavigator

extension OnboardingCoordinator: SignUpLogInNavigator {
    func cancelSignUpLogIn() {
        dismissCurrentNavigationController()
    }

    func closeSignUpLogIn(myUser: MyUser) {
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }

    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        // scammer alert is ignored in on-boarding
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }

    func openRecaptcha(transparentMode: Bool) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = RecaptchaViewModel(transparentMode: transparentMode)
        vm.navigator = self
        let backgroundImage: UIImage? = transparentMode ? viewController.presentingViewController?.view.takeSnapshot() : nil
        let vc = RecaptchaViewController(viewModel: vm, backgroundImage: backgroundImage)
        if transparentMode {
            vc.modalTransitionStyle = .crossDissolve
        }
        navCtl.present(vc, animated: true, completion: nil)
    }

    func openRememberPasswordFromSignUpLogIn(email: String?) {
        openRememberPassword(email: email)
    }

    func openHelpFromSignUpLogin() {
        openHelp()
    }

}

// MARK: - V2
// MARK: - SignUpEmailStep1Navigator

extension OnboardingCoordinator: SignUpEmailStep1Navigator {
    func cancelSignUpEmailStep1() {
        dismissCurrentNavigationController()
    }

    func openHelpFromSignUpEmailStep1() {
        openHelp()
    }

    func openNextStepFromSignUpEmailStep1(email: String, password: String,
                                          isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = SignUpEmailStep2ViewModel(email: email, isRememberedEmail: isRememberedEmail,
                                           password: password, source: .install, collapsedEmail: collapsedEmail)
        vm.navigator = self
        let vc = SignUpEmailStep2ViewController(viewModel: vm, appearance: .dark,
                                                backgroundImage: loginV2BackgroundImage)
        navCtl.pushViewController(vc, animated: true)

        recaptchaTokenDelegate = vm
    }

    func openLogInFromSignUpEmailStep1(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = LogInEmailViewModel(email: email, isRememberedEmail: isRememberedEmail,
                                     source: .install, collapsedEmail: collapsedEmail)
        vm.navigator = self
        let vc = LogInEmailViewController(viewModel: vm, appearance: .dark,
                                          backgroundImage: loginV2BackgroundImage)
        let navCtlVCs: [UIViewController] = navCtl.viewControllers.dropLast() + [vc]
        navCtl.setViewControllers(navCtlVCs, animated: false)
    }
}


// MARK: - SignUpEmailStep2Navigator

extension OnboardingCoordinator: SignUpEmailStep2Navigator {
    func openHelpFromSignUpEmailStep2() {
        openHelp()
    }

    func openRecaptchaFromSignUpEmailStep2(transparentMode: Bool) {
        openRecaptcha(transparentMode: transparentMode)
    }

    func openScammerAlertFromSignUpEmailStep2(contactURL: URL) {
        // scammer alert is ignored in on-boarding
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }

    func closeAfterSignUpSuccessful() {
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }
}


// MARK: - LogInEmailNavigator

extension OnboardingCoordinator: LogInEmailNavigator {
    func cancelLogInEmail() {
        dismissCurrentNavigationController()
    }

    func openHelpFromLogInEmail() {
        openHelp()
    }

    func openRememberPasswordFromLogInEmail(email: String?) {
        openRememberPassword(email: email)
    }

    func openSignUpEmailFromLogInEmail(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = SignUpEmailStep1ViewModel(email: email,
                                           isRememberedEmail: isRememberedEmail,
                                           source: .install,
                                           collapsedEmail: collapsedEmail)
        vm.navigator = self

        let vc = SignUpEmailStep1ViewController(viewModel: vm,
                                                appearance: .dark,
                                                backgroundImage: loginV2BackgroundImage)
        let navCtlVCs: [UIViewController] = navCtl.viewControllers.dropLast() + [vc]
        navCtl.setViewControllers(navCtlVCs, animated: false)
    }

    func openScammerAlertFromLogInEmail(contactURL: URL) {
        // scammer alert is ignored in on-boarding
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }

    func closeAfterLogInSuccessful() {
        dismissCurrentNavigationController { [weak self] in
            self?.tourLoginFinish()
        }
    }
}


fileprivate extension OnboardingCoordinator {
    var loginV2BackgroundImage: UIImage? {
        let vc = presentedViewControllers.last ?? viewController
        return vc.view.takeSnapshot()
    }
}


// MARK: - RecaptchaNavigator

extension OnboardingCoordinator: RecaptchaNavigator {
    func recaptchaClose() {
        guard let recaptchaVC = currentNavigationController()?.presentedViewController as? RecaptchaViewController else {
            return
        }
        recaptchaVC.dismiss(animated: true, completion: nil)
    }

    func recaptchaFinishedWithToken(_ token: String) {
        guard let recaptchaVC = currentNavigationController()?.presentedViewController as? RecaptchaViewController else {
            return
        }
        recaptchaVC.dismiss(animated: true) { [weak self] in
            self?.recaptchaTokenDelegate?.recaptchaTokenObtained(token: token)
        }
    }
}


// MARK: - RememberPasswordNavigator

extension OnboardingCoordinator: RememberPasswordNavigator {
    func closeRememberPassword() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - HelpNavigator

extension OnboardingCoordinator: HelpNavigator {
    func closeHelp() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - Common Navigator

extension OnboardingCoordinator {
    func openURL(url: URL) {
        if let vc = currentNavigationController() {
            if #available(iOS 9.0, *) {
                let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
                svc.view.tintColor = UIColor.primaryColor
                vc.present(svc, animated: true, completion: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}


// MARK: - Private methods

fileprivate extension OnboardingCoordinator {
    func openHelp() {
        guard let navCtl = currentNavigationController() else { return }

        let vm = HelpViewModel()
        vm.navigator = self
        let vc = HelpViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openRememberPassword(email: String?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = RememberPasswordViewModel(source: .install, email: email)
        vm.navigator = self
        let vc = RememberPasswordViewController(viewModel: vm, appearance: .dark)
        navCtl.pushViewController(vc, animated: true)
    }

    func dismissCurrentNavigationController(completion: (() -> ())? = nil) {
        currentNavigationController()?.dismiss(animated: true, completion: completion)
    }

    func currentNavigationController() -> UINavigationController? {
        let topVC = topViewController()
        return topVC.presentedViewController as? UINavigationController
    }
}
