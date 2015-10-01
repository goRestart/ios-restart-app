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
    
    required init(coder: NSCoder) {
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
    
    func viewModel(viewModel: LogInViewModel, didFinishLoggingInWithResult result: Result<User, UserLogInEmailServiceError>) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            let message: String
            switch (error.value) {
            case .InvalidEmail:
                message = NSLocalizedString("log_in_error_send_error_invalid_email", comment: "")
            case .InvalidPassword:
                message = String(format: NSLocalizedString("log_in_error_send_error_invalid_password", comment: ""), Constants.passwordMinLength)
            case .UserNotFoundOrWrongPassword:
                message = NSLocalizedString("log_in_error_send_error_user_not_found_or_wrong_password", comment: "")
            case .Network:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .Internal, .Forbidden:
                message = NSLocalizedString("log_in_error_send_error_generic", comment: "")
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
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
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateViewModelText(text, fromTextFieldTag: textField.tag)
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
        setLetGoNavigationBarStyle(title: NSLocalizedString("log_in_title", comment: ""))
        emailTextField.placeholder = NSLocalizedString("log_in_email_field_hint", comment: "")
        passwordTextField.placeholder = NSLocalizedString("log_in_password_field_hint", comment: "")
        rememberPasswordButton.setTitle(NSLocalizedString("log_in_reset_password_button", comment: ""), forState: .Normal)
        logInButton.setTitle(NSLocalizedString("log_in_send_button", comment: ""), forState: .Normal)
        
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