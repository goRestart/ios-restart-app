//
//  SignUpEmailStep2ViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class SignUpEmailStep2ViewController: KeyboardViewController, SignUpEmailStep2ViewModelDelegate {
    fileprivate let viewModel: SignUpEmailStep2ViewModel
    fileprivate let signUpEmailStep2View: SignUpEmailStep2View
    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: SignUpEmailStep2ViewModel,
                     appearance: LoginAppearance,
                     backgroundImage: UIImage?) {
        self.init(viewModel: viewModel,
                  appearance: appearance,
                  backgroundImage: backgroundImage,
                  deviceFamily: DeviceFamily.current)
    }

    init(viewModel: SignUpEmailStep2ViewModel,
         appearance: LoginAppearance,
         backgroundImage: UIImage?,
         deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.signUpEmailStep2View = SignUpEmailStep2View(appearance: appearance,
                                                         backgroundImage: backgroundImage,
                                                         deviceFamily: deviceFamily,
                                                         termsAndConditionsAcceptRequired: viewModel.termsAndConditionsAcceptRequired,
                                                         newsLetterAcceptRequired: viewModel.newsLetterAcceptRequired)
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)
        viewModel.delegate = self
        signUpEmailStep2View.keyboardView = keyboardView
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

extension SignUpEmailStep2ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            signUpEmailStep2View.scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
        }

        signUpEmailStep2View.fullNameImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            signUpEmailStep2View.scrollView.bounces = false  // Disable scroll bouncing when no editing
        }

        signUpEmailStep2View.fullNameImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if signUpEmailStep2View.signUpButton.isEnabled {
            signUpPressed()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !string.hasEmojis()
    }
}


// MARK: - UITextViewDelegate

extension SignUpEmailStep2ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
}


// MARK: - Private
// MARK: > UI


fileprivate extension SignUpEmailStep2ViewController {
    func setupNavigationBar() {
        title = LGLocalizedString.signUpEmailStep2Title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.signUpEmailStep2HelpButton,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(openHelp))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        signUpEmailStep2View.headerLabel.text = LGLocalizedString.signUpEmailStep2Header(viewModel.email)
        signUpEmailStep2View.fullNameTextField.text = viewModel.username.value
        signUpEmailStep2View.fullNameTextField.delegate = self

        if viewModel.termsAndConditionsAcceptRequired {
            if let termsURL = viewModel.termsAndConditionsURL, let privacyURL = viewModel.privacyURL {
                let linkColor = UIColor.grayText
                let links = [LGLocalizedString.signUpEmailStep2TermsConditionsTermsKw: termsURL,
                             LGLocalizedString.signUpEmailStep2TermsConditionsPrivacyKw: privacyURL]
                let termsText = LGLocalizedString.signUpEmailStep2TermsConditions
                let attrTermsText = termsText.attributedHyperlinkedStringWithURLDict(links, textColor: linkColor)
                attrTermsText.addAttribute(NSFontAttributeName, value: UIFont.mediumBodyFont,
                                           range: NSMakeRange(0, attrTermsText.length))
                signUpEmailStep2View.termsTextView.attributedText = attrTermsText
            } else {
                signUpEmailStep2View.termsTextView.text = LGLocalizedString.signUpTermsConditions
            }
            signUpEmailStep2View.termsTextView.delegate = self
            signUpEmailStep2View.termsSwitch.isOn = viewModel.termsAndConditionsAccepted.value
        }

        if viewModel.newsLetterAcceptRequired {
            signUpEmailStep2View.newsletterSwitch.isOn = viewModel.newsLetterAccepted.value
        }
    }

    dynamic func openHelp() {
        viewModel.helpButtonPressed()
    }

    dynamic func makeFullNameFirstResponder() {
        signUpEmailStep2View.fullNameTextField.becomeFirstResponder()
    }

    func signUpPressed() {
        let errors = viewModel.signUpButtonPressed()
        openAlertWithFormErrors(errors: errors)
    }

    func openAlertWithFormErrors(errors: SignUpEmailStep2FormErrors) {
        guard !errors.isEmpty else { return }

        if errors.contains(.invalidEmail) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidEmail)
        } else if errors.contains(.invalidPassword) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                                                                                                  Constants.passwordMaxLength))
        } else if errors.contains(.usernameContainsLetgo) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorGeneric)
        } else if errors.contains(.shortUsername) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength))
        } else if errors.contains(.termsAndConditionsNotAccepted) {
            showAutoFadingOutMessageAlert(LGLocalizedString.signUpAcceptanceError)
        }
    }
}


// MARK: > Rx

fileprivate extension SignUpEmailStep2ViewController {
    func setupRx() {
        signUpEmailStep2View.fullNameButton.rx.tap.subscribeNext { [weak self] _ in
            self?.makeFullNameFirstResponder()
        }.addDisposableTo(disposeBag)

        signUpEmailStep2View.fullNameTextField.rx.text.bindTo(viewModel.username).addDisposableTo(disposeBag)

        signUpEmailStep2View.termsSwitch.rx.value.bindTo(viewModel.termsAndConditionsAccepted).addDisposableTo(disposeBag)

        signUpEmailStep2View.newsletterSwitch.rx.value.bindTo(viewModel.newsLetterAccepted).addDisposableTo(disposeBag)

        viewModel.signUpEnabled.bindTo(signUpEmailStep2View.signUpButton.rx.isEnabled).addDisposableTo(disposeBag)

        signUpEmailStep2View.signUpButton.rx.tap.subscribeNext { [weak self] _ in
            self?.signUpPressed()
        }.addDisposableTo(disposeBag)
    }
}
