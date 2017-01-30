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
        case email = 1000, password
    }

    fileprivate let viewModel: LogInEmailViewModel
    fileprivate let appearance: LoginAppearance
    fileprivate let deviceFamily: DeviceFamily

    fileprivate let scrollView = UIScrollView()
    fileprivate let headerGradientView = UIView()
    fileprivate let headerGradientLayer = CAGradientLayer.gradientWithColor(UIColor.white,
                                                                            alphas: [1, 0], locations: [0, 1])
    fileprivate let contentView = UIView()
    fileprivate let emailButton = UIButton()
    fileprivate let emailImageView = UIImageView()
    fileprivate let emailTextField = LGTextField()
    fileprivate let passwordButton = UIButton()
    fileprivate let passwordImageView = UIImageView()
    fileprivate let passwordTextField = LGTextField()
    fileprivate let rememberPasswordButton = UIButton()
    fileprivate let loginButton = UIButton()
    fileprivate let footerButton = UIButton()

    fileprivate var lines: [CALayer] = []

    fileprivate let loginButtonVisible = Variable<Bool>(true)

    fileprivate let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(viewModel: LogInEmailViewModel, appearance: LoginAppearance) {
        self.init(viewModel: viewModel, appearance: appearance, deviceFamily: DeviceFamily.current)
    }

    init(viewModel: LogInEmailViewModel, appearance: LoginAppearance, deviceFamily: DeviceFamily) {
        self.viewModel = viewModel
        self.appearance = appearance
        self.deviceFamily = deviceFamily
        super.init(viewModel: viewModel, nibName: nil,
                   statusBarStyle: appearance.statusBarStyle,
                   navBarBackgroundStyle: appearance.navBarBackgroundStyle)

        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: try moving this to init
        setupNavigationBar()
        setupUI()
        setupLayout()
        setupRx()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateUI()
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
            self?.viewModel.enableGodMode(godPassword: godPassword)
        }
        alertController.addAction(loginAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - UITextFieldDelegate

extension LogInEmailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = true  // Enable scroll bouncing so the keyboard is easy to dismiss on drag
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = emailImageView
        case .password:
            iconImageView = passwordImageView
        }
        iconImageView.isHighlighted = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        defer {
            scrollView.bounces = false  // Disable scroll bouncing when no editing
            adjustScrollViewContentOffset()
        }

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }

        let iconImageView: UIImageView
        switch tag {
        case .email:
            iconImageView = emailImageView
        case .password:
            iconImageView = passwordImageView
        }
        iconImageView.isHighlighted = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag

        if textField.returnKeyType == .next {
            guard let nextView = view.viewWithTag(tag + 1) else { return true }
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LGLocalizedString.logInEmailHelpButton, style: .plain,
                                                            target: self, action: #selector(openHelp))
    }

    func setupUI() {
        view.backgroundColor = UIColor.white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)

        headerGradientView.translatesAutoresizingMaskIntoConstraints = false
        headerGradientView.backgroundColor = UIColor.clear
        headerGradientView.isOpaque = true
        headerGradientView.layer.addSublayer(headerGradientLayer)
//        headerGradientLayer.frame = headerGradientView.bounds
        headerGradientView.layer.sublayers?.removeAll()
        headerGradientView.layer.insertSublayer(headerGradientLayer, at: 0)
        headerGradientView.isHidden = appearance.headerGradientIsHidden
        view.addSubview(headerGradientView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let textfieldTextColor = UIColor.blackText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha

        emailButton.translatesAutoresizingMaskIntoConstraints = false
        emailButton.setStyle(appearance.textFieldButtonStyle)
        emailButton.addTarget(self, action: #selector(makeEmailTextFieldFirstResponder), for: .touchUpInside)
        contentView.addSubview(emailButton)

        emailImageView.translatesAutoresizingMaskIntoConstraints = false
        emailImageView.image = appearance.emailIcon(highlighted: false)
        emailImageView.highlightedImage = appearance.emailIcon(highlighted: true)
        emailImageView.contentMode = .center
        contentView.addSubview(emailImageView)

        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.tag = TextFieldTag.email.rawValue
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .next
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.logInEmailEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        emailTextField.clearButtonOffset = 0
        emailTextField.delegate = self
        contentView.addSubview(emailTextField)

        passwordButton.translatesAutoresizingMaskIntoConstraints = false
        passwordButton.setStyle(appearance.textFieldButtonStyle)
        passwordButton.addTarget(self, action: #selector(makePasswordTextFieldFirstResponder), for: .touchUpInside)
        contentView.addSubview(passwordButton)

        passwordImageView.translatesAutoresizingMaskIntoConstraints = false
        passwordImageView.image = appearance.passwordIcon(highlighted: false)
        passwordImageView.highlightedImage = appearance.passwordIcon(highlighted: true)
        passwordImageView.contentMode = .center
        contentView.addSubview(passwordImageView)

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.tag = TextFieldTag.password.rawValue
        passwordTextField.keyboardType = .default
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .send
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.logInEmailPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        passwordTextField.clearButtonOffset = 0
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)

        rememberPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        rememberPasswordButton.setTitle(LGLocalizedString.logInEmailForgotPasswordButton, for: .normal)
        rememberPasswordButton.setTitleColor(UIColor.darkGrayText, for: .normal)
        contentView.addSubview(rememberPasswordButton)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setStyle(.primary(fontSize: .medium))
        loginButton.setTitle(LGLocalizedString.logInEmailLogInButton, for: .normal)
        contentView.addSubview(loginButton)

        let footerString = (LGLocalizedString.logInEmailFooter as NSString)
        let footerAttrString = NSMutableAttributedString(string: LGLocalizedString.logInEmailFooter)

        let footerStringRange = NSRange(location: 0, length: footerString.length)
        let signUpKwRange = footerString.range(of: LGLocalizedString.logInEmailFooterSignUpKw)

        if signUpKwRange.location != NSNotFound {
            let prefix = footerString.substring(to: signUpKwRange.location)
            let prefixRange = footerString.range(of: prefix)
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: prefixRange)

            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.primaryColor,
                                          range: signUpKwRange)
        } else {
            footerAttrString.addAttribute(NSForegroundColorAttributeName, value: appearance.footerMainTextColor,
                                          range: footerStringRange)
        }

        footerButton.translatesAutoresizingMaskIntoConstraints = false
        footerButton.setTitleColor(UIColor.darkGrayText, for: .normal)
        footerButton.setAttributedTitle(footerAttrString, for: .normal)
        footerButton.titleLabel?.numberOfLines = 2
        footerButton.contentHorizontalAlignment = .center
        view.addSubview(footerButton)
    }

    func setupLayout() {
        scrollView.layout(with: topLayoutGuide).vertically()
        scrollView.layout(with: bottomLayoutGuide).vertically(invert: true)
        scrollView.layout(with: view).leading().trailing()

        headerGradientView.layout(with: topLayoutGuide).vertically()
        headerGradientView.layout(with: view).leading().trailing()
        headerGradientView.layout().height(20)

        contentView.layout(with: scrollView).top().leading().proportionalWidth()

        emailButton.layout(with: contentView).top(by: 30).leading(by: 15).trailing(by: -15)
        emailButton.layout().height(50)
        emailImageView.layout().width(20)
        emailImageView.layout(with: emailButton).top().bottom().leading(by: 15)
        emailTextField.layout(with: emailButton).top().bottom().leading(by: 30).trailing(by: -8)

        passwordButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        passwordButton.layout(with: emailButton).vertically()
        passwordButton.layout().height(50)
        passwordImageView.layout().width(20)
        passwordImageView.layout(with: passwordButton).top().bottom().leading(by: 15)
        passwordTextField.layout(with: passwordButton).top().bottom().leading(by: 30).trailing(by: -8)

        rememberPasswordButton.layout(with: passwordButton).vertically(by: 5)
        rememberPasswordButton.layout(with: contentView).leading(by: 15).trailing(by: -15)
        rememberPasswordButton.layout().height(45, relatedBy: .greaterThanOrEqual)

        loginButton.layout(with: rememberPasswordButton).vertically(by: 5)
        loginButton.layout(with: contentView).leading(by: 15).trailing(by: -15).bottom(by: 15)
        loginButton.layout().height(50)

        if deviceFamily.isWiderOrEqualThan(.iPhone6) {
            footerButton.layout(with: keyboardView).bottom(to: .top)
        } else {
            footerButton.layout(with: view).bottom()
        }
        footerButton.layout(with: view).leading(by: 15).trailing(by: -15)
        footerButton.layout().height(55, relatedBy: .greaterThanOrEqual)
    }

    func updateUI() {
        // Update gradient frame
        headerGradientLayer.frame = headerGradientView.bounds

        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        lines.append(passwordButton.addTopBorderWithWidth(1, color: appearance.lineColor))

        // Redraw masked rounded corners & corner radius
        emailButton.setRoundedCorners([.topLeft, .topRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        passwordButton.setRoundedCorners([.bottomLeft, .bottomRight], cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        loginButton.layer.cornerRadius = loginButton.bounds.height/2
    }

    func adjustScrollViewContentOffset() {
        let focusedTextFields = [emailTextField, passwordTextField].flatMap { $0 }.filter { $0.isFirstResponder }
        if let focusedTextField = focusedTextFields.first, !loginButtonVisible.value {
            let y = focusedTextField.frame.origin.y
            let offset = CGPoint(x: 0, y: y - emailTextField.frame.origin.y)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }

    dynamic func openHelp() {
        viewModel.openHelp()
    }

    dynamic func makeEmailTextFieldFirstResponder() {
        emailTextField.becomeFirstResponder()
    }

    dynamic func makePasswordTextFieldFirstResponder() {
        passwordTextField.becomeFirstResponder()
    }
}

// TODO: Move this to a separate extension file
fileprivate extension LoginAppearance {
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .dark:
            return .lightContent
        case .light:
            return .default
        }
    }

    var navBarBackgroundStyle: NavBarBackgroundStyle {
        switch self {
        case .dark:
            return .transparent(substyle: .dark)
        case .light:
            return .transparent(substyle: .light)
        }
    }

    var headerGradientIsHidden: Bool {
        switch self {
        case .dark:
            return true
        case .light:
            return false
        }
    }

    var textFieldButtonStyle: ButtonStyle {
        switch self {
        case .dark:
            return .darkField
        case .light:
            return .lightField
        }
    }

    var lineColor: UIColor {
        switch self {
        case .dark:
            return UIColor.black
        case .light:
            return UIColor.white
        }
    }

    func emailIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return #imageLiteral(resourceName: "ic_email_active_dark")
            } else {
                return #imageLiteral(resourceName: "ic_email_dark")
            }
        case .light:
            if highlighted {
                return #imageLiteral(resourceName: "ic_email_active")
            } else {
                return #imageLiteral(resourceName: "ic_email")
            }
        }
    }

    func passwordIcon(highlighted: Bool) -> UIImage? {
        switch self {
        case .dark:
            if highlighted {
                return #imageLiteral(resourceName: "ic_password_active_dark")
            } else {
                return #imageLiteral(resourceName: "ic_password_dark")
            }
        case .light:
            if highlighted {
                return #imageLiteral(resourceName: "ic_password_active")
            } else {
                return #imageLiteral(resourceName: "ic_password")
            }
        }
    }

    var footerMainTextColor: UIColor {
        switch self {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.darkGrayText
        }
    }
}


// MARK: > Rx

fileprivate extension LogInEmailViewController {
    func setupRx() {
        emailTextField.rx.text.bindTo(viewModel.email).addDisposableTo(disposeBag)
        passwordTextField.rx.text.bindTo(viewModel.password).addDisposableTo(disposeBag)
        viewModel.logInEnabled.bindTo(loginButton.rx.isEnabled).addDisposableTo(disposeBag)
        rememberPasswordButton.rx.tap.subscribeNext {
            [weak self] _ in self?.viewModel.openRememberPassword()
        }.addDisposableTo(disposeBag)
        loginButton.rx.tap.subscribeNext { [weak self] _ in self?.loginButtonPressed() }.addDisposableTo(disposeBag)
        footerButton.rx.tap.subscribeNext { [weak self] _ in
            self?.viewModel.openSignUp()
        }.addDisposableTo(disposeBag)

        // Login button is visible depending on current content offset & keyboard visibility
        Observable.combineLatest(scrollView.rx.contentOffset.asObservable(), keyboardChanges.asObservable()) { ($0, $1) }
            .map { [weak self] (offset, keyboardChanges) -> Bool in
                guard let strongSelf = self else { return false }
                let scrollY = offset.y
                let scrollHeight = strongSelf.scrollView.frame.height
                let scrollMaxY = scrollY + scrollHeight

                let scrollVisibleMaxY: CGFloat
                if keyboardChanges.visible {
                    scrollVisibleMaxY = scrollMaxY - keyboardChanges.height
                } else {
                    scrollVisibleMaxY = scrollMaxY
                }
                let buttonMaxY = strongSelf.loginButton.frame.maxY
                return scrollVisibleMaxY > buttonMaxY
        }.bindTo(loginButtonVisible).addDisposableTo(disposeBag)
    }
}


// MARK: >

fileprivate extension LogInEmailViewController {
    func loginButtonPressed() {
        let errors = viewModel.logIn()
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


