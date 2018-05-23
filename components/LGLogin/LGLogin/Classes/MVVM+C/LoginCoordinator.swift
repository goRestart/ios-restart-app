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

public enum LoginStyle {
    case fullScreen
    case popup(String)
}

public protocol RecaptchaTokenDelegate: class {
    func recaptchaTokenObtained(token: String, action: LoginActionType)
}

public final class LoginCoordinator: Coordinator, ChangePasswordPresenter {
    public var child: Coordinator?
    public var viewController: UIViewController
    public weak var coordinatorDelegate: CoordinatorDelegate?
    public weak var presentedAlertController: UIAlertController?
    public let bubbleNotificationManager: BubbleNotificationManager
    public let sessionManager: SessionManager

    fileprivate var parentViewController: UIViewController?
    fileprivate var presentedViewControllers: [UIViewController] = []
    fileprivate weak var recaptchaTokenDelegate: RecaptchaTokenDelegate?

    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let style: LoginStyle
    fileprivate let loggedInAction: () -> Void
    fileprivate let cancelAction: (() -> Void)?

    fileprivate let tracker: Tracker

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(source: EventParameterLoginSourceValue,
         style: LoginStyle,
         loggedInAction: @escaping (() -> Void),
         cancelAction: (() -> Void)?,
         bubbleNotificationManager: BubbleNotificationManager,
         tracker: Tracker,
         sessionManager: SessionManager,
         termsAndConditionsEnabled: Bool) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.source = source
        self.style = style
        self.loggedInAction = loggedInAction
        self.cancelAction = cancelAction

        self.tracker = tracker
        self.sessionManager = sessionManager
        let viewModel = SignUpViewModel(appearance: LoginAppearance.light,
                                        source: source,
                                        termsAndConditionsEnabled: termsAndConditionsEnabled)
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

    func openChangePassword(coordinator: ChangePasswordCoordinator) {
        openChild(coordinator: coordinator, parent: topPresentedController(), animated: true, forceCloseChild: true, completion: nil)
    }

    public func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }

        parentViewController = parent
        viewController.modalPresentationStyle = .overFullScreen
        parent.present(viewController, animated: animated, completion: completion)
    }

    public func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        if let vc = presentedViewControllers.last {
            presentedViewControllers.removeLast()
            vc.dismissWithPresented(animated: false) { [weak self] in
                self?.dismissViewController(animated: animated, completion: completion)
            }
        } else {
            viewController.dismissWithPresented(animated: animated, completion: completion)
        }
    }
}


// MARK: - MainSignUpNavigator

extension LoginCoordinator: MainSignUpNavigator {
    public func cancelMainSignUp() {
        closeRoot(didLogIn: false)
    }

    public func closeMainSignUpSuccessful(with myUser: MyUser) {
        closeRoot(didLogIn: true)
    }

    public func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    public func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }

    public func openSignUpEmailFromMainSignUp(termsAndConditionsEnabled: Bool) {
        let vc: UIViewController
        let vm = SignUpLogInViewModel(
            source: source, action:
            LoginActionType.signup,
            termsAndConditionsEnabled: termsAndConditionsEnabled)
        vm.navigator = self
        vc = SignUpLogInViewController(viewModel: vm,
                                       appearance: .light,
                                       keyboardFocus: false)
        recaptchaTokenDelegate = vm


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

    public func openLogInEmailFromMainSignUp(termsAndConditionsEnabled: Bool) {
        let vc: UIViewController

        let vm = SignUpLogInViewModel(
            source: source,
            action: LoginActionType.login,
            termsAndConditionsEnabled: termsAndConditionsEnabled)
        vm.navigator = self
        vc = SignUpLogInViewController(viewModel: vm,
                                       appearance: .light,
                                       keyboardFocus: false)

        recaptchaTokenDelegate = vm

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

    public func openHelpFromMainSignUp() {
        openHelp()
    }
}

// MARK: - V1
// MARK: - SignUpLogInNavigator

extension LoginCoordinator: SignUpLogInNavigator {

    public func cancelSignUpLogIn() {
        // called when closing from popup login so it's not closing root only presented controller
        dismissLastPresented(animated: true, completion: nil)
    }

    public func closeSignUpLogInSuccessful(with myUser: MyUser) {
        closeRoot(didLogIn: true)
    }

    public func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    public func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenDeviceNotAllowedAlert(contactURL: contactURL, network: network)
    }

    public func openRecaptcha(action: LoginActionType) {
        let topVC = topViewController()

        let vm = RecaptchaViewModel(action: action)
        vm.navigator = self
        let vc = RecaptchaViewController(viewModel: vm)
        presentedViewControllers.append(vc)
        topVC.present(vc, animated: true, completion: nil)
    }

    public func openRememberPasswordFromSignUpLogIn(email: String?) {
        openRememberPassword(email: email)
    }

    public func openHelpFromSignUpLogin() {
        openHelp()
    }
}


// MARK: - RememberPasswordNavigator

extension LoginCoordinator: RememberPasswordNavigator {
    public func closeRememberPassword() {
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
    public func recaptchaClose() {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true, completion: nil)
    }

    public func recaptchaFinishedWithToken(_ token: String, action: LoginActionType) {
        guard topViewController() is RecaptchaViewController else { return }
        dismissLastPresented(animated: true) { [weak self] in
            self?.recaptchaTokenDelegate?.recaptchaTokenObtained(token: token, action: action)
        }
    }
}

// MARK: - Common Navigator

extension LoginCoordinator {
    public func open(url: URL) {
        let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
        svc.view.tintColor = UIColor.primaryColor
        let vc = topViewController()
        vc.present(svc, animated: true, completion: nil)
    }
}


// MARK: - Private

fileprivate extension LoginCoordinator {
    func closeRoot(didLogIn: Bool) {
        closeCoordinator(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            if didLogIn {
                strongSelf.loggedInAction()
            } else {
                if let action = strongSelf.cancelAction {
                    action()
                }
            }
        }
    }

    func closeRootAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        dismissViewController(animated: true) { [weak self] in
            let contact = UIAction(
                interface: .button(R.Strings.loginScammerAlertContactButton, .primary(fontSize: .medium)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .accountUnderReview))
                    self?.closeCoordinator(animated: false) {
                        self?.parentViewController?.openInternalUrl(contactURL)
                    }

            })
            let keepBrowsing = UIAction(
                interface: .button(R.Strings.loginScammerAlertKeepBrowsingButton, .secondary(fontSize: .medium,
                                                                                                     withBorder: false)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .accountUnderReview))
                    self?.closeCoordinator(animated: false, completion: nil)
            })
            let actions = [contact, keepBrowsing]
            self?.parentViewController?.showAlertWithTitle(R.Strings.loginScammerAlertTitle,
                                                           text: R.Strings.loginScammerAlertMessage,
                                                           alertType: .iconAlert(icon: #imageLiteral(resourceName: "ic_moderation_alert")),
                                                           buttonsLayout: .vertical, actions: actions)
            self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .accountUnderReview))
        }
    }

    func closeRootAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        dismissViewController(animated: true) { [weak self] in
            let contact = UIAction(
                interface: .button(R.Strings.loginDeviceNotAllowedAlertContactButton, .primary(fontSize: .medium)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network, reason: .secondDevice))
                    self?.closeCoordinator(animated: false) {
                        self?.parentViewController?.openInternalUrl(contactURL)
                    }

            })
            let keepBrowsing = UIAction(
                interface: .button(R.Strings.loginDeviceNotAllowedAlertOkButton, .secondary(fontSize: .medium,
                                                                                                     withBorder: false)),
                action: {
                    self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network, reason: .secondDevice))
                    self?.closeCoordinator(animated: false, completion: nil)
            })
            let actions = [contact, keepBrowsing]
            self?.parentViewController?.showAlertWithTitle(R.Strings.loginDeviceNotAllowedAlertTitle,
                                                           text: R.Strings.loginDeviceNotAllowedAlertMessage,
                                                           alertType: .iconAlert(icon: #imageLiteral(resourceName: "ic_device_blocked_alert")),
                                                           buttonsLayout: .vertical, actions: actions)
            self?.tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network, reason: .secondDevice))
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

    func topPresentedController() -> UIViewController {
        var current = topViewController()
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }

    func dismissLastPresented(animated: Bool, completion: (() -> Void)?) {
        guard let lastPresented = presentedViewControllers.last else {
            completion?()
            return
        }
        presentedViewControllers.removeLast()
        lastPresented.dismiss(animated: animated, completion: completion)
    }
}
