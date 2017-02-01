//
//  LoginCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation

import LGCoreKit
import RxSwift

protocol LoginCoordinatorDelegate: CoordinatorDelegate {
//    func loginCoordinatorDidCancel(_ coordinator: LoginCoordinator)
//    func loginCoordinatorWillFinish(_ coordinator: LoginCoordinator)
//    func loginCoordinatorDidFinishWithFailure(_ coordinator: LoginCoordinator)
//    func loginCoordinator(_ coordinator: LoginCoordinator, didFinishWithMyUser myUser: MyUser)
}

final class LoginCoordinator: Coordinator {
    var child: Coordinator?

    fileprivate var parentViewController: UIViewController?
    var viewController: UIViewController
    var presentedAlertController: UIAlertController?

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

    convenience init(source: EventParameterLoginSourceValue, appearance: LoginAppearance, style: LoginStyle,
                     preDismissLoginBlock: (() -> Void)?,
                     loggedInAction: @escaping (() -> Void)) {
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        self.init(source: source, appearance: appearance, style: style,
                  preDismissLoginBlock: preDismissLoginBlock, loggedInAction: loggedInAction,
                  keyValueStorage: keyValueStorage, tracker: tracker, featureFlags: featureFlags)
    }

    init(source: EventParameterLoginSourceValue, appearance: LoginAppearance, style: LoginStyle,
         preDismissLoginBlock: (() -> Void)?, loggedInAction: @escaping (() -> Void),
         keyValueStorage: KeyValueStorage, tracker: Tracker, featureFlags: FeatureFlags) {
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
        close(MainSignUpViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
//            strongSelf.delegate?.loginCoordinatorDidCancel(strongSelf)
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
        }
    }

    func closeMainSignUp(myUser: MyUser) {
//        delegate?.loginCoordinatorWillFinish(self)
        close(MainSignUpViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
//            strongSelf.delegate?.loginCoordinator(strongSelf, didFinishWithMyUser: myUser)
            strongSelf.delegate?.coordinatorDidClose(strongSelf)
        }
    }

    func closeMainSignUpAndOpenScammerAlert(network: EventParameterAccountNetwork) {
//        delegate?.loginCoordinatorWillFinish(self)
        close(MainSignUpViewController.self, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
//            strongSelf.delegate?.loginCoordinatorDidFinishWithFailure(strongSelf)
            // TODO: Open scammer
//            strongSelf.delegate?.coordinatorDidClose(strongSelf)
        }
    }

    func openSignUpEmailFromMainSignUp(source: EventParameterLoginSourceValue,
                                       collapsedEmailParam: EventParameterCollapsedEmailField?) {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .signup)
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)
        navCtl.pushViewController(vc, animated: true)
    }

    func openLogInEmailFromMainSignUp(source: EventParameterLoginSourceValue,
                                      collapsedEmailParam: EventParameterCollapsedEmailField?) {
        guard let navCtl = viewController as? UINavigationController else { return }

        let vm = SignUpLogInViewModel(source: source, collapsedEmailParam: collapsedEmailParam, action: .login)
        let vc = SignUpLogInViewController(viewModel: vm, appearance: appearance, keyboardFocus: false)
        navCtl.pushViewController(vc, animated: true)
    }
}
