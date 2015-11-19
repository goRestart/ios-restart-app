//
//  LogInViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class LogInViewController: BaseViewController, LogInViewModelDelegate, UITextFieldDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000, Password
    }

    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: LogInViewModel!
    
    // UI
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var rememberPasswordButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue) {
        self.viewModel = LogInViewModel(source: source)
        self.lines = []
        super.init(viewModel: viewModel, nibName: "LogInViewController")
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }

    // MARK: - Actions
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func rememberPasswordButtonPressed(sender: AnyObject) {
        let vc = RememberPasswordViewController(source: viewModel.loginSource)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        viewModel.logIn()
    }
    
    // MARK: - LogInViewModelDelegate
    
    func viewModel(viewModel: LogInViewModel, updateSendButtonEnabledState enabled: Bool) {
        logInButton.enabled = enabled
    }
    
    func viewModelDidStartLoggingIn(viewModel: LogInViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: LogInViewModel, didFinishLoggingInWithResult result: UserLogInEmailServiceResult) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            let message: String
            switch (error) {
            case .InvalidEmail:
                message = LGLocalizedString.logInErrorSendErrorInvalidEmail
            case .InvalidPassword:
                message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
            case .UserNotFoundOrWrongPassword:
                message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal, .Forbidden:
                message = LGLocalizedString.logInErrorSendErrorGeneric
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            viewModel.logIn()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let textFieldText = textField.text {
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
        }
        return true
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Navigation bar
        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        logInButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        logInButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        logInButton.layer.cornerRadius = 4
        
        // i18n
        setLetGoNavigationBarStyle(LGLocalizedString.logInTitle)
        emailTextField.placeholder = LGLocalizedString.logInEmailFieldHint
        passwordTextField.placeholder = LGLocalizedString.logInPasswordFieldHint
        rememberPasswordButton.setTitle(LGLocalizedString.logInResetPasswordButton, forState: .Normal)
        logInButton.setTitle(LGLocalizedString.logInSendButton, forState: .Normal)
        
        emailTextField.tintColor = StyleHelper.textFieldTintColor
        passwordTextField.tintColor = StyleHelper.textFieldTintColor

        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }
    
    // MARK: > Helper
    
    private func updateViewModelText(text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            case .Password:
                viewModel.password = text
            }
        }
    }
}