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

protocol LoginCoordinatorDelegate: CoordinatorDelegate {
    // TODO: ⚠️
//    func loginCoordinatorDidCancel(_ coordinator: LoginCoordinator)
//    func loginCoordinatorWillFinish(_ coordinator: LoginCoordinator)
//    func loginCoordinatorDidFinishWithFailure(_ coordinator: LoginCoordinator)
//    func loginCoordinator(_ coordinator: LoginCoordinator, didFinishWithMyUser myUser: MyUser)
}

final class LoginCoordinator: Coordinator {
    var child: Coordinator?
    var viewController: UIViewController
    weak var presentedAlertController: UIAlertController?
    let bubbleNotificationManager: BubbleNotificationManager

    fileprivate var parentViewController: UIViewController?

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
        close()
    }

    func closeMainSignUp(myUser: MyUser) {
////        delegate?.loginCoordinatorWillFinish(self)
//        close(animated: true) { [weak self] in
//            guard let strongSelf = self else { return }
////            strongSelf.delegate?.loginCoordinator(strongSelf, didFinishWithMyUser: myUser)
//            strongSelf.delegate?.coordinatorDidClose(strongSelf)
//        }
        close()
    }

    func closeMainSignUpAndOpenScammerAlert(network: EventParameterAccountNetwork) {
////        delegate?.loginCoordinatorWillFinish(self)
//        close(animated: true) { [weak self] in
//            guard let strongSelf = self else { return }
////            strongSelf.delegate?.loginCoordinatorDidFinishWithFailure(strongSelf)
//            // TODO: ⚠️ Open scammer
////            strongSelf.delegate?.coordinatorDidClose(strongSelf)
//        }
        close()
    }

    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?) {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .signup)
        vm.navigator = self
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)
        navCtl.pushViewController(vc, animated: true)
    }

    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?) {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .login)
        vm.navigator = self
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)
        navCtl.pushViewController(vc, animated: true)
    }

    func openHelpFromMainSignUp() {
        openHelp()
    }

    func openTermsAndConditionsFromMainSignUp() {
        openTermsAndConditions()
    }

    func openPrivacyPolicyFromMainSignUp() {
        openPrivacyPolicy()
    }
}


// MARK: - SignUpLogInNavigator

extension LoginCoordinator: SignUpLogInNavigator {
    func cancelSignUpLogIn() {
        close()
    }

    func closeSignUpLogIn(myUser: MyUser) {
        close()
    }

    func closeSignUpLogInAndOpenScammerAlert(network: EventParameterAccountNetwork) {
        close()
        // TODO: ⚠️
    }

    func openRecaptcha(transparentMode: Bool) {
        // TODO: ⚠️
    }

    func openRememberPasswordFromSignUpLogIn(email: String) {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vm = RememberPasswordViewModel(source: source, email: email)
        vm.navigator = self
        let vc = RememberPasswordViewController(viewModel: vm, appearance: appearance)
        navCtl.pushViewController(vc, animated: true)

    }

    func openHelpFromSignUpLogin() {
        openHelp()
    }

    func openTermsAndConditionsFromSignUpLogin() {
        openTermsAndConditions()
    }

    func openPrivacyPolicyFromSignUpLogin() {
        openPrivacyPolicy()
    }
}


// MARK: - RememberPasswordNavigator

extension LoginCoordinator: RememberPasswordNavigator {
    func closeRememberPassword() {
        guard let navCtl = viewController as? UINavigationController,
              navCtl.topViewController is RememberPasswordViewController else { return }
        navCtl.popViewController(animated: true)
    }
}


// MARK: - Private

fileprivate extension LoginCoordinator {
    func close() {
        close(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
        }
    }

    func openHelp() {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vc = HelpViewController()
        navCtl.pushViewController(vc, animated: true)
    }

    func openTermsAndConditions() {
        guard let url = LetgoURLHelper.buildTermsAndConditionsURL() else { return }
        openURL(url: url)
    }

    func openPrivacyPolicy() {
        guard let url = LetgoURLHelper.buildPrivacyURL() else { return }
        openURL(url: url)
    }

    func openURL(url: URL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            svc.view.tintColor = UIColor.primaryColor
            viewController.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
