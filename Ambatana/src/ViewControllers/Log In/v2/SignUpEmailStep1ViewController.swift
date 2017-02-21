//
//  SignUpEmailStep1ViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class SignUpEmailStep1ViewController: KeyboardViewController {
    fileprivate enum TextFieldTag: Int {
        case email = 1000, password
    }

    fileprivate let viewModel: SignUpEmailStep1ViewModel
    fileprivate let signUpEmailStep1View: SignUpEmailStep1View
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: SignUpEmailStep1ViewModel,
                     appearance: LoginAppearance,
                     backgroundImage: UIImage?) {
        self.init(viewModel: viewModel,
                  appearance: appearance,
                  backgroundImage: backgroundImage,
                  deviceFamily: DeviceFamily.current)
    }

    init(viewModel: SignUpEmailStep1ViewModel,
         appearance: LoginAppearance,
         backgroundImage: UIImage?,
         deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.signUpEmailStep1View = SignUpEmailStep1View(appearance: appearance,
                                                         backgroundImage: backgroundImage,
                                                         deviceFamily: deviceFamily)
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)
        signUpEmailStep1View.keyboardView = keyboardView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupRx()
    }
}


// MARK: - UITextFieldDelegate

extension SignUpEmailStep1ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            signUpEmailStep1View.scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = signUpEmailStep1View.emailImageView
        case .password:
            iconImageView = signUpEmailStep1View.passwordImageView
        }
        iconImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            signUpEmailStep1View.scrollView.bounces = false  // Disable scroll bouncing when no editing
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = signUpEmailStep1View.emailImageView
            signUpEmailStep1View.emailTextField.suggestion = nil
        case .password:
            iconImageView = signUpEmailStep1View.passwordImageView
        }
        iconImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag

        if textField.returnKeyType == .next {
            guard let nextView = view.viewWithTag(tag + 1) else { return true }

            if tag == TextFieldTag.email.rawValue && viewModel.acceptSuggestedEmail() {
                signUpEmailStep1View.emailTextField.text = viewModel.email.value
            }
            nextView.becomeFirstResponder()
            return false
        } else {
            nextStepButtonPressed()
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


fileprivate extension SignUpEmailStep1ViewController {
    func setupNavigationBar() {
        title = LGLocalizedString.signUpEmailStep1Title

        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain, target: self,
                                              action: #selector(closeButtonPressed))
            navigationItem.leftBarButtonItem = closeButton
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.signUpEmailStep1HelpButton, style: .plain,
                                                            target: self, action: #selector(openHelp))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        signUpEmailStep1View.translatesAutoresizingMaskIntoConstraints = false
        signUpEmailStep1View.addToViewController(self, inView: view)

        signUpEmailStep1View.emailTextField.text = viewModel.email.value
        signUpEmailStep1View.emailTextField.tag = TextFieldTag.email.rawValue
        signUpEmailStep1View.emailTextField.delegate = self

        signUpEmailStep1View.passwordTextField.text = viewModel.password.value
        signUpEmailStep1View.passwordTextField.tag = TextFieldTag.password.rawValue
        signUpEmailStep1View.passwordTextField.delegate = self
    }

    func adjustScrollViewContentOffset() {
        let focusedTextFields = [signUpEmailStep1View.emailTextField, signUpEmailStep1View.passwordTextField]
            .flatMap { $0 }
            .filter { $0.isFirstResponder }

        if let focusedTextField = focusedTextFields.first, !signUpEmailStep1View.nextStepButtonVisible.value {
            let y = focusedTextField.frame.origin.y
            let offset = CGPoint(x: 0, y: y - signUpEmailStep1View.emailTextField.frame.origin.y)
            signUpEmailStep1View.scrollView.setContentOffset(offset, animated: true)
        } else {
            signUpEmailStep1View.scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    dynamic func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    dynamic func openHelp() {
        viewModel.helpButtonPressed()
    }

    dynamic func makeEmailTextFieldFirstResponder() {
        signUpEmailStep1View.emailTextField.becomeFirstResponder()
    }

    dynamic func makePasswordTextFieldFirstResponder() {
        signUpEmailStep1View.passwordTextField.becomeFirstResponder()
    }

    func showPasswordPressed() {
        signUpEmailStep1View.passwordTextField.isSecureTextEntry = !signUpEmailStep1View.passwordTextField.isSecureTextEntry
        signUpEmailStep1View.showPasswordButton.isSelected = !signUpEmailStep1View.passwordTextField.isSecureTextEntry

        // workaround to avoid weird font type
        signUpEmailStep1View.passwordTextField.font = UIFont(name: "systemFont", size: 17)
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha
        signUpEmailStep1View.passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailStep1PasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
    }

    func nextStepButtonPressed() {
        let errors = viewModel.nextStepButtonPressed()
        openAlertWithFormErrors(errors: errors)
    }

    func openAlertWithFormErrors(errors: SignUpEmailStep1FormErrors) {
        guard !errors.isEmpty else { return }

        if errors.contains(.invalidEmail) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorInvalidEmail)
        } else if errors.contains(.shortPassword) || errors.contains(.longPassword) {
            showAutoFadingOutMessageAlert(LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword)
        }
    }
}


// MARK: > Rx

fileprivate extension SignUpEmailStep1ViewController {
    func setupRx() {
        signUpEmailStep1View.emailButton.rx.tap.subscribeNext { [weak self] _ in
            self?.makeEmailTextFieldFirstResponder()
        }.addDisposableTo(disposeBag)

        signUpEmailStep1View.emailTextField.rx.text.bindTo(viewModel.email).addDisposableTo(disposeBag)
        viewModel.suggestedEmail.asObservable().subscribeNext { [weak self] suggestedEmail in
            self?.signUpEmailStep1View.emailTextField.suggestion = suggestedEmail
        }.addDisposableTo(disposeBag)

        signUpEmailStep1View.passwordButton.rx.tap.subscribeNext { [weak self] _ in
            self?.makePasswordTextFieldFirstResponder()
        }.addDisposableTo(disposeBag)

        signUpEmailStep1View.passwordTextField.rx.text.bindTo(viewModel.password).addDisposableTo(disposeBag)

        viewModel.password.asObservable().map { password -> Bool in
            guard let password = password else { return true }
            return password.isEmpty
        }.bindTo(signUpEmailStep1View.showPasswordButton.rx.isHidden).addDisposableTo(disposeBag)

        viewModel.nextStepEnabled.bindTo(signUpEmailStep1View.nextStepButton.rx.isEnabled).addDisposableTo(disposeBag)

        signUpEmailStep1View.showPasswordButton.rx.tap.subscribeNext { [weak self] _ in self?.showPasswordPressed() }.addDisposableTo(disposeBag)

        signUpEmailStep1View.nextStepButton.rx.tap.subscribeNext { [weak self] _ in
            self?.nextStepButtonPressed()
        }.addDisposableTo(disposeBag)

        signUpEmailStep1View.footerButton.rx.tap.subscribeNext { [weak self] _ in
            self?.viewModel.footerButtonPressed()
        }.addDisposableTo(disposeBag)

        // Next button is visible depending on current content offset & keyboard visibility
        Observable.combineLatest(signUpEmailStep1View.scrollView.rx.contentOffset.asObservable(),
                                 keyboardChanges.asObservable()) { ($0, $1) }
            .map { [weak self] (offset, keyboardChanges) -> Bool in
                guard let strongSelf = self else { return false }
                let scrollY = offset.y
                let scrollHeight = strongSelf.signUpEmailStep1View.scrollView.frame.height
                let scrollMaxY = scrollY + scrollHeight

                let scrollVisibleMaxY: CGFloat
                if keyboardChanges.visible {
                    scrollVisibleMaxY = scrollMaxY - keyboardChanges.height
                } else {
                    scrollVisibleMaxY = scrollMaxY
                }
                let buttonMaxY = strongSelf.signUpEmailStep1View.nextStepButton.frame.maxY
                return scrollVisibleMaxY > buttonMaxY
            }.bindTo(signUpEmailStep1View.nextStepButtonVisible).addDisposableTo(disposeBag)
    }
}
