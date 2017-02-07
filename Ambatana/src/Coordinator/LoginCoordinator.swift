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

final class LoginCoordinator: Coordinator {
    var child: Coordinator?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager

    fileprivate var parentViewController: UIViewController?
    fileprivate weak var signUpLogInViewModel: SignUpLogInViewModel?  // TODO: ⚠️ this is a bit weird

    fileprivate let appearance: LoginAppearance
    fileprivate let source: EventParameterLoginSourceValue
    fileprivate let style: LoginStyle
    fileprivate let preDismissLoginBlock: (() -> Void)?
    fileprivate let loggedInAction: () -> Void

    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    weak var delegate: LoginCoordinatorDelegate?

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(source: EventParameterLoginSourceValue,
                     appearance: LoginAppearance,
                     style: LoginStyle,
                     preDismissLoginBlock: (() -> Void)?,
                     loggedInAction: @escaping (() -> Void)) {
        self.init(source: source,
                  appearance: appearance,
                  style: style,
                  preDismissLoginBlock: preDismissLoginBlock,
                  loggedInAction: loggedInAction,
                  bubbleNotificationManager: BubbleNotificationManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(source: EventParameterLoginSourceValue,
         appearance: LoginAppearance,
         style: LoginStyle,
         preDismissLoginBlock: (() -> Void)?,
         loggedInAction: @escaping (() -> Void),
         bubbleNotificationManager: BubbleNotificationManager,
         keyValueStorage: KeyValueStorage,
         tracker: Tracker,
         featureFlags: FeatureFlags) {
        self.bubbleNotificationManager = bubbleNotificationManager
        self.appearance = appearance
        self.source = source
        self.style = style
        self.preDismissLoginBlock = preDismissLoginBlock
        self.loggedInAction = loggedInAction

        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.featureFlags = featureFlags

        let viewModel = SignUpViewModel(appearance: appearance, source: source)
        switch style {
        case .fullScreen:
            let mainSignUpVC = MainSignUpViewController(viewModel: viewModel)
            mainSignUpVC.afterLoginAction = loggedInAction
            let navCtl = UINavigationController(rootViewController: mainSignUpVC)
            navCtl.view.backgroundColor = UIColor.white
            self.viewController = navCtl
        case .popup(let message):
            let popUpSignUpVC = PopupSignUpViewController(viewModel: viewModel, topMessage: message)
            popUpSignUpVC.preDismissAction = preDismissLoginBlock
            popUpSignUpVC.afterLoginAction = loggedInAction
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
        closeRoot()
    }

    func closeMainSignUp(myUser: MyUser) {
        closeRoot()
    }

    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?) {
        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .signup)
        vm.navigator = self
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)

        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            viewController.present(navCtl, animated: true, completion: nil)
        }

        signUpLogInViewModel = vm
    }

    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?) {
        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .login)
        vm.navigator = self
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)

        switch style {
        case .fullScreen:
            guard let navCtl = viewController as? UINavigationController else { return }

            navCtl.pushViewController(vc, animated: true)

        case .popup:
            guard viewController is PopupSignUpViewController else { return }

            let navCtl = UINavigationController(rootViewController: vc)
            viewController.present(navCtl, animated: true, completion: nil)
        }

        signUpLogInViewModel = vm
    }

    func openHelpFromMainSignUp() {
        openHelp()
    }
}


// MARK: - SignUpLogInNavigator

extension LoginCoordinator: SignUpLogInNavigator {
    func cancelSignUpLogIn() {
        close(animated: true, completion: nil)
    }

    func closeSignUpLogIn(myUser: MyUser) {
        closeRoot()
    }

    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        closeRootAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    func openRecaptcha(transparentMode: Bool) {
        let vm = RecaptchaViewModel(transparentMode: transparentMode)
        vm.navigator = self
        // TODO: ⚠️ instead of presentingViewController ask coordinator delegate
        let backgroundImage: UIImage? = transparentMode ? viewController.presentingViewController?.view.takeSnapshot() : nil
        let vc = RecaptchaViewController(viewModel: vm, backgroundImage: backgroundImage)
        if transparentMode {
            vc.modalTransitionStyle = .crossDissolve
        }
        viewController.present(vc, animated: true, completion: nil)
    }

    func openRememberPasswordFromSignUpLogIn(email: String) {
        guard let navCtl = navigationController else { return }

        let vm = RememberPasswordViewModel(source: source, email: email)
        vm.navigator = self
        let vc = RememberPasswordViewController(viewModel: vm, appearance: appearance)
        navCtl.pushViewController(vc, animated: true)

    }

    func openHelpFromSignUpLogin() {
        openHelp()
    }
}


// MARK: - RememberPasswordNavigator

extension LoginCoordinator: RememberPasswordNavigator {
    func closeRememberPassword() {
        guard let navCtl = navigationController else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - HelpNavigator

extension LoginCoordinator: HelpNavigator {
    func closeHelp() {
        guard let navCtl = navigationController else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - RecaptchaNavigator

extension LoginCoordinator: RecaptchaNavigator {
    func recaptchaClose() {
        close(animated: true, completion: nil)
    }

    func recaptchaFinishedWithToken(_ token: String) {
        close(animated: true) { [weak self] in
            self?.signUpLogInViewModel?.recaptchaTokenObtained(token)
        }
    }
}


// MARK: - Common Navigator

extension LoginCoordinator {
    func openURL(url: URL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            let vc = navigationController ?? viewController
            vc.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}


// MARK: - Private

fileprivate extension LoginCoordinator {
    func closeRoot() {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
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
        guard let navCtl = navigationController else { return }

        let vm = HelpViewModel()
        vm.navigator = self
        let vc = HelpViewController(viewModel: vm)
        navCtl.pushViewController(vc, animated: true)
    }

    var navigationController: UINavigationController? {
        switch style {
        case .fullScreen:
            return viewController as? UINavigationController
        case .popup:
            return viewController.presentedViewController as? UINavigationController
        }
    }
}
