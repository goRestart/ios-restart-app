//
//  LoginCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import SafariServices

enum LoginStyle {
    case fullScreen
    case popup(String)
}

protocol LoginCoordinatorDelegate: CoordinatorDelegate {}

protocol RecaptchaTokenDelegate: class {
    func recaptchaTokenObtained(token: String)
}

final class LoginCoordinator: Coordinator {
    var child: Coordinator?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager
    let sessionManager: SessionManager

    fileprivate var parentViewController: UIViewController?
    fileprivate var presentedViewControllers: [UIViewController] = []
    fileprivate weak var recaptchaTokenDelegate: RecaptchaTokenDelegate?

    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let style: LoginStyle
    fileprivate let loggedInAction: () -> Void

    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    weak var delegate: LoginCoordinatorDelegate?

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: EventParameterLoginSourceValue,
                     style: LoginStyle,
                     loggedInAction: @escaping (() -> Void)) {
        self.init(source: source,
                  style: style,
                  loggedInAction: loggedInAction,
                  bubbleNotificationManager: LGBubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  sessionManager: Core.sessionManager)
    }

    init(source: EventParameterLoginSourceValue,
         style: LoginStyle,
         loggedInAction: @escaping (() -> Void),
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags,
         sessionManager: SessionManager) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.source = source
        self.style = style
        self.loggedInAction = loggedInAction

        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.sessionManager = sessionManager
        let viewModel = SignUpViewModel(appearance: .light, source: source)
        switch style {
        case .fullScreen:
            let mainSignUpVC = MainSignUpViewController(viewModel: viewModel)
            let navCtl = UINavigationController(rootViewController: mainSignUpVC)
            self.viewController = navCtl
        case .popup(let message):
            let popUpSignUpVC = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
            self.viewController = popUpSignUpVC
        }
        viewModel.navigator = self
    }

    func open(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        parent.present(viewController, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: (() -> Void)?) {
        close(UIViewController.self, animated: animated, completion: completion)
    }
}

fileprivate extension LoginCoordinator {
    func close<T: UIViewController>(_ type: T.Type, animated: Bool, completion: (() -> Void)?) {
        let dismiss: () -> Void = { [weak self] in
            guard let viewController = self?.viewController as? T else { return }
            viewController.dismiss(animated: animated, completion: completion)
        }

        if let child = child {
            child.close(animated: animated, completion: dismiss)
        } else {
            dismiss()
        }
    }
}


// MARK: - MainSignUpNavigator

extension LoginCoordinator: MainSignUpNavigator {
    func cancelMainSignUp() {
        closeRoot(didLogIn: false)
    }

    func closeMainSignUpSuccessful(with myUser: MyUser) {
        closeRoot(didLogIn: true)
    }

    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?) {
        let vc: UIViewController

        switch featureFlags.signUpLoginImprovement {
        case .v1, .v1WImprovements:
            let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .signup)
            vm.navigator = self
            vc = SignUpLogInViewController(viewModel: vm,
                                           appearance: .light,
                                           keyboardFocus: false)
            recaptchaTokenDelegate = vm
        case .v2:
            let vm = SignUpEmailStep1ViewModel(source: source, collapsedEmail: collapsedEmailParam)
            vm.navigator = self

            vc = SignUpEmailStep1ViewController(viewModel: vm, appearance: .light, backgroundImage: nil)
        }

        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            presentedViewControllers.append(navCtl)
            viewController.present(navCtl, animated: true, completion: nil)
        }
    }

    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?) {
        let vc: UIViewController

        switch featureFlags.signUpLoginImprovement {
        case .v1, .v1WImprovements:
            let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .login)
            vm.navigator = self
            vc = SignUpLogInViewController(viewModel: vm, appearance: .light, keyboardFocus: false)

            recaptchaTokenDelegate = vm
        case .v2:
            let vm = LogInEmailViewModel(source: source,
                                         collapsedEmail: collapsedEmailParam)
            vm.navigator = self
            vc = LogInEmailViewController(viewModel: vm,
                                          appearance: .light,
                                          backgroundImage: nil)
        }

        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            presentedViewControllers.append(navCtl)
            viewController.present(navCtl, animated: true, completion: nil)
        }
    }

    func openHelpFromMainSignUp() {
        openHelp()
    }
}

// MARK: - V1
// MARK: - SignUpLogInNavigator

extension LoginCoordinator: SignUpLogInNavigator {
    func cancelSignUpLogIn() {
        dismissLastPresented(animated: true, completion: nil)
    }

    func closeSignUpLogInSuccessful(with myUser: MyUser) {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRoot(didLogIn: true)
        }
    }

    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
        }
    }

    func openRecaptcha(transparentMode: Bool) {
        let topVC = topViewController()

        let vm = RecaptchaViewModel(transparentMode: transparentMode)
        vm.navigator = self
        let backgroundImage: UIImage? = transparentMode ? viewController.presentingViewController?.view.takeSnapshot() : nil
        let vc = RecaptchaViewController(viewModel: vm, backgroundImage: backgroundImage)
        if transparentMode {
            vc.modalTransitionStyle = .crossDissolve
        }
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
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

extension LoginCoordinator: SignUpEmailStep1Navigator {
    func cancelSignUpEmailStep1() {
        dismissLastPresented(animated: true, completion: nil)
    }

    func openHelpFromSignUpEmailStep1() {
        openHelp()
    }

    func openNextStepFromSignUpEmailStep1(email: String, password: String,
                                          isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = SignUpEmailStep2ViewModel(email: email, isRememberedEmail: isRememberedEmail,
                                           password: password, source: source, collapsedEmail: collapsedEmail)
        vm.navigator = self
        let vc = SignUpEmailStep2ViewController(viewModel: vm, appearance: .light, backgroundImage: nil)
        navCtl.pushViewController(vc, animated: true)

        recaptchaTokenDelegate = vm
    }

    func openLogInFromSignUpEmailStep1(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = LogInEmailViewModel(email: email, isRememberedEmail: isRememberedEmail,
                                     source: source, collapsedEmail: collapsedEmail)
        vm.navigator = self
        let vc = LogInEmailViewController(viewModel: vm, appearance: .light, backgroundImage: nil)
        // In popup mode we want to replace the first VC and it's not possible with pop + push
        let navCtlVCs: [UIViewController] = navCtl.viewControllers.dropLast() + [vc]
        navCtl.setViewControllers(navCtlVCs, animated: false)
    }
}


// MARK: - SignUpEmailStep2Navigator

extension LoginCoordinator: SignUpEmailStep2Navigator {
    func openHelpFromSignUpEmailStep2() {
        openHelp()
    }

    func openRecaptchaFromSignUpEmailStep2(transparentMode: Bool) {
        let topVC = topViewController()

        let vm = RecaptchaViewModel(transparentMode: transparentMode)
        vm.navigator = self
        let backgroundImage: UIImage? = transparentMode ? viewController.presentingViewController?.view.takeSnapshot() : nil
        let vc = RecaptchaViewController(viewModel: vm, backgroundImage: backgroundImage)
        if transparentMode {
            vc.modalTransitionStyle = .crossDissolve
        }
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }

    func openScammerAlertFromSignUpEmailStep2(contactURL: URL) {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRootAndOpenScammerAlert(contactURL: contactURL, network: .email)
        }
    }

    func closeAfterSignUpSuccessful() {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRoot(didLogIn: true)
        }
    }
}


// MARK: - LogInEmailNavigator

extension LoginCoordinator: LogInEmailNavigator {
    func cancelLogInEmail() {
        dismissLastPresented(animated: true, completion: nil)
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
                                           source: source,
                                           collapsedEmail: collapsedEmail)
        vm.navigator = self

        let vc = SignUpEmailStep1ViewController(viewModel: vm,
                                                appearance: .light,
                                                backgroundImage: nil)
        let navCtlVCs: [UIViewController] = navCtl.viewControllers.dropLast() + [vc]
        navCtl.setViewControllers(navCtlVCs, animated: false)
    }

    func openScammerAlertFromLogInEmail(contactURL: URL) {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRootAndOpenScammerAlert(contactURL: contactURL, network: .email)
        }
    }

    func closeAfterLogInSuccessful() {
        dismissAllPresentedIfNeededAndExecute { [weak self] in
            self?.closeRoot(didLogIn: true)
        }
    }
}


// MARK: - RememberPasswordNavigator

extension LoginCoordinator: RememberPasswordNavigator {
    func closeRememberPassword() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - HelpNavigator

extension LoginCoordinator: HelpNavigator {
    func closeHelp() {
        guard let navCtl = currentNavigationController() else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - RecaptchaNavigator

extension LoginCoordinator: RecaptchaNavigator {
    func recaptchaClose() {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true, completion: nil)
    }

    func recaptchaFinishedWithToken(_ token: String) {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true) { [weak self] in
            self?.recaptchaTokenDelegate?.recaptchaTokenObtained(token: token)
        }
    }
}

// MARK: - Common Navigator

extension LoginCoordinator {
    func open(url: URL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            let vc = topViewController()
            presentedViewControllers.append(vc)
            vc.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}


// MARK: - Private

fileprivate extension LoginCoordinator {
    func closeRoot(didLogIn: Bool) {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
            if didLogIn {
                strongSelf.loggedInAction()
            }
        }
    }

    func closeRootAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        close(animated: true) { [weak self] in
            let contact = UIAction(
                interface: .button(LGLocalizedString.loginScammerAlertContactButton, .primary(fontSize: .medium)),
                action: {
                    guard let strongSelf = self else { return }
                    strongSelf.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network))
                    strongSelf.parentViewController?.openInternalUrl(contactURL)
                    strongSelf.delegate?.coordinatorDidClose(strongSelf)

                })
            let keepBrowsing = UIAction(
                interface: .button(LGLocalizedString.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                                     withBorder: false)),
                action: {
                    guard let strongSelf = self else { return }
                    strongSelf.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network))
                    strongSelf.delegate?.coordinatorDidClose(strongSelf)
                })
            let actions = [contact, keepBrowsing]
            self?.parentViewController?.showAlertWithTitle(LGLocalizedString.loginScammerAlertTitle,
                                                           text: LGLocalizedString.loginScammerAlertMessage,
                                                           alertType: .iconAlert(icon: #imageLiteral(resourceName: "ic_moderation_alert")),
                                                           buttonsLayout: .vertical, actions: actions)
        }
    }

    func openHelp() {
        guard let navCtl = currentNavigationController() else { return }

        let vm = HelpViewModel()
        vm.navigator = self
        let vc = HelpViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    func openRememberPassword(email: String?) {
        guard let navCtl = currentNavigationController() else { return }

        let vm = RememberPasswordViewModel(source: source, email: email)
        vm.navigator = self
        let vc = RememberPasswordViewController(viewModel: vm, appearance: .light)
        navCtl.pushViewController(vc, animated: true)
    }

    fileprivate func topViewController() -> UIViewController {
        return presentedViewControllers.last ?? viewController
    }

    func currentNavigationController() -> UINavigationController? {
        return topViewController() as? UINavigationController
    }

    func dismissLastPresented(animated: Bool, completion: (() -> Void)?) {
        guard let lastPresented = presentedViewControllers.last else {
            completion?()
            return
        }
        presentedViewControllers.removeLast()
        lastPresented.dismiss(animated: animated, completion: completion)
    }

    func dismissAllPresentedIfNeededAndExecute(completion: @escaping () -> Void) {
        if let vc = presentedViewControllers.last {
            presentedViewControllers.removeLast()
            vc.dismissAllPresented {
                vc.dismiss(animated: false) { [weak self] in
                    self?.dismissAllPresentedIfNeededAndExecute(completion: completion)
                }
            }
        } else {
            viewController.dismissAllPresented(completion)
        }
    }
}
