//
//  LogInEmailViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class LogInEmailViewController: KeyboardViewController {
    fileprivate enum TextFieldTag: Int {
        case email = 1000
        case password
    }

    fileprivate let viewModel: LogInEmailViewModel
    fileprivate var logInEmailView: LogInEmailView
    fileprivate let deviceFamily: DeviceFamily
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: LogInEmailViewModel,
                     appearance: LoginAppearance,
                     backgroundImage: UIImage?) {
        self.init(viewModel: viewModel,
                  appearance: appearance,
                  backgroundImage: backgroundImage,
                  deviceFamily: DeviceFamily.current)
    }

    init(viewModel: LogInEmailViewModel,
         appearance: LoginAppearance,
         backgroundImage: UIImage?,
         deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.logInEmailView = LogInEmailView(appearance: appearance,
                                             backgroundImage: backgroundImage)
        self.deviceFamily = deviceFamily
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupRx()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - LogInEmailViewModelDelegate

extension LogInEmailViewController: LogInEmailViewModelDelegate {
    func vmGodModePasswordAlert() {
        let alertController = UIAlertController(title: "🔑", message: "Speak friend and enter", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let loginAction = UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first else { return }
            let godPassword = textField.text ?? ""
            self?.viewModel.godModePasswordTyped(godPassword: godPassword)
        }
        alertController.addAction(loginAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UITextFieldDelegate

extension LogInEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            logInEmailView.scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = logInEmailView.emailImageView
        case .password:
            iconImageView = logInEmailView.passwordImageView
        }
        iconImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            logInEmailView.scrollView.bounces = false  // Disable scroll bouncing when no editing
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = logInEmailView.emailImageView
            logInEmailView.emailTextField.suggestion = nil
        case .password:
            iconImageView = logInEmailView.passwordImageView
        }
        iconImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag

        if textField.returnKeyType == .next {
            guard let nextView = view.viewWithTag(tag + 1) else { return true }

            if tag == TextFieldTag.email.rawValue && viewModel.acceptSuggestedEmail() {
                logInEmailView.emailTextField.text = viewModel.email.value
            }
            nextView.becomeFirstResponder()
            return false
        } else {
            loginButtonPressed()
            return true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !string.hasEmojis()
    }
}


// MARK: - Private
// MARK: > UI


fileprivate extension LogInEmailViewController {
    func setupNavigationBar() {
        title = LGLocalizedString.logInEmailTitle

        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain, target: self,
                                              action: #selector(closeButtonPressed))
            navigationItem.leftBarButtonItem = closeButton
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.logInEmailHelpButton, style: .plain,
                                                            target: self, action: #selector(helpButtonPressed))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        logInEmailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logInEmailView)
        logInEmailView.layout(with: view).left().right()
        logInEmailView.layout(with: topLayoutGuide).top(to: .bottom)
        if deviceFamily.isWiderOrEqualThan(.iPhone6) {
            logInEmailView.layout(with: keyboardView).bottom(to: .top)
        } else {
            logInEmailView.layout(with: bottomLayoutGuide).bottom(to: .top)
        }
        
        logInEmailView.emailTextField.text = viewModel.email.value
        logInEmailView.emailTextField.tag = TextFieldTag.email.rawValue
        logInEmailView.emailTextField.delegate = self

        logInEmailView.passwordTextField.text = viewModel.password.value
        logInEmailView.passwordTextField.tag = TextFieldTag.password.rawValue
        logInEmailView.passwordTextField.delegate = self
    }

    func adjustScrollViewContentOffset() {
        let focusedTextFields = [logInEmailView.emailTextField, logInEmailView.passwordTextField]
            .flatMap { $0 }
            .filter { $0.isFirstResponder }
        if let focusedTextField = focusedTextFields.first, !logInEmailView.loginButtonVisible.value {
            let y = focusedTextField.frame.origin.y
            let offset = CGPoint(x: 0, y: y - logInEmailView.emailTextField.frame.origin.y)
            logInEmailView.scrollView.setContentOffset(offset, animated: true)
        } else {
            logInEmailView.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    dynamic func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    dynamic func helpButtonPressed() {
        viewModel.helpButtonPressed()
    }

    dynamic func makeEmailTextFieldFirstResponder() {
        logInEmailView.emailTextField.becomeFirstResponder()
    }

    dynamic func makePasswordTextFieldFirstResponder() {
        logInEmailView.passwordTextField.becomeFirstResponder()
    }

    func showPasswordPressed() {
        logInEmailView.passwordTextField.isSecureTextEntry = !logInEmailView.passwordTextField.isSecureTextEntry
        logInEmailView.showPasswordButton.isSelected = !logInEmailView.passwordTextField.isSecureTextEntry

        // workaround to avoid weird font type
        logInEmailView.passwordTextField.font = UIFont(name: "systemFont", size: 17)
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha
        logInEmailView.passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep1PasswordFieldHint,
                                                                                    attributes: textfieldPlaceholderAttrs)
    }

    func loginButtonPressed() {
        let errors = viewModel.logInButtonPressed()
        openAlertWithFormErrors(errors: errors)
    }

    func openAlertWithFormErrors(errors: LogInEmailFormErrors) {
        guard !errors.isEmpty else { return }

        if errors.contains(.invalidEmail) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorInvalidEmail)
        } else if errors.contains(.shortPassword) || errors.contains(.longPassword) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword)
        }
    }
}


// MARK: > Rx

fileprivate extension LogInEmailViewController {
    func setupRx() {
        logInEmailView.emailButton.rx.tap.subscribeNext { [weak self] _ in
            self?.makeEmailTextFieldFirstResponder()
        }.addDisposableTo(disposeBag)

        logInEmailView.emailTextField.rx.text.bindTo(viewModel.email).addDisposableTo(disposeBag)

        viewModel.suggestedEmail.asObservable().subscribeNext { [weak self] suggestedEmail in
            self?.logInEmailView.emailTextField.suggestion = suggestedEmail
        }.addDisposableTo(disposeBag)

        logInEmailView.passwordButton.rx.tap.subscribeNext { [weak self] _ in
            self?.makePasswordTextFieldFirstResponder()
        }.addDisposableTo(disposeBag)

        logInEmailView.passwordTextField.rx.text.bindTo(viewModel.password).addDisposableTo(disposeBag)

        viewModel.password.asObservable().map { password -> Bool in
            guard let password = password else { return true }
            return password.isEmpty
        }.bindTo(logInEmailView.showPasswordButton.rx.isHidden).addDisposableTo(disposeBag)

        viewModel.logInEnabled.bindTo(logInEmailView.loginButton.rx.isEnabled).addDisposableTo(disposeBag)

        logInEmailView.rememberPasswordButton.rx.tap.subscribeNext { [weak self] _ in
            self?.viewModel.rememberPasswordButtonPressed()
        }.addDisposableTo(disposeBag)

        logInEmailView.showPasswordButton.rx.tap.subscribeNext { [weak self] _ in
            self?.showPasswordPressed()
        }.addDisposableTo(disposeBag)

        logInEmailView.loginButton.rx.tap.subscribeNext { [weak self] _ in
            self?.loginButtonPressed()
        }.addDisposableTo(disposeBag)

        logInEmailView.footerButton.rx.tap.subscribeNext { [weak self] _ in
            self?.viewModel.footerButtonPressed()
        }.addDisposableTo(disposeBag)

        // Login button is visible depending on current content offset & keyboard visibility
        Observable.combineLatest(logInEmailView.scrollView.rx.contentOffset.asObservable(),
                                 keyboardChanges.asObservable()) { ($0, $1) }
            .map { [weak self] (offset, keyboardChanges) -> Bool in
                guard let strongSelf = self else { return false }
                let scrollY = offset.y
                let scrollHeight = strongSelf.logInEmailView.scrollView.frame.height
                let scrollMaxY = scrollY + scrollHeight

                let scrollVisibleMaxY: CGFloat
                if keyboardChanges.visible {
                    scrollVisibleMaxY = scrollMaxY - keyboardChanges.height
                } else {
                    scrollVisibleMaxY = scrollMaxY
                }
                let buttonMaxY = strongSelf.logInEmailView.loginButton.frame.maxY
                return scrollVisibleMaxY > buttonMaxY
        }.bindTo(logInEmailView.loginButtonVisible).addDisposableTo(disposeBag)
    }
}
