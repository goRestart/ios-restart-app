//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class SignUpViewController: BaseViewController, SignUpViewModelDelegate, UITextFieldDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Username = 1000, Email, Password
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: SignUpViewModel!
    
    // UI
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!

    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue) {
        self.viewModel = SignUpViewModel(source: source)
        self.lines = []
        super.init(viewModel: viewModel, nibName: "SignUpViewController")
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        usernameTextField.becomeFirstResponder()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
        lines.append(passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }
    
    // MARK: - Actions
    
    @IBAction func usernameButtonPressed(sender: AnyObject) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        viewModel.signUp()
    }
    
    // MARK: - SignUpViewModelDelegate
    
    func viewModel(viewModel: SignUpViewModel, updateSendButtonEnabledState enabled: Bool) {
        signUpButton.enabled = enabled
    }
    
    func viewModelDidStartSigningUp(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpViewModel, didFinishSigningUpWithResult result: UserSignUpServiceResult) {
        
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
                message = NSLocalizedString("sign_up_send_error_invalid_email", comment: "")
            case .InvalidUsername:
                message = String(format: NSLocalizedString("sign_up_send_error_invalid_username", comment: ""), Constants.fullNameMinLength)
            case .InvalidPassword:
                message = String(format: NSLocalizedString("sign_up_send_error_invalid_password_with_max", comment: ""), Constants.passwordMinLength, Constants.passwordMaxLength)
            case .Network:
                message = NSLocalizedString("common_error_connection_failed", comment: "")
            case .EmailTaken:
                message = NSLocalizedString("sign_up_send_error_email_taken", comment: "")
            case .UsernameTaken:
                message = String(format: NSLocalizedString("sign_up_send_error_invalid_username_letgo", comment: ""), viewModel.username)
            case .Internal:
                message = NSLocalizedString("sign_up_send_error_generic", comment: "")
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
            case .Username:
                iconImageView = usernameIconImageView
            case .Email:
                iconImageView = emailIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = true
        }
        scrollView.setContentOffset(CGPointMake(0,textField.frame.origin.y), animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Username:
                iconImageView = usernameIconImageView
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
            viewModel.signUp()
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
    
    private func setupUI() {
        // Appearance
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        signUpButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        signUpButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)

        signUpButton.layer.cornerRadius = 4
        
        // i18n
        setLetGoNavigationBarStyle(NSLocalizedString("sign_up_title", comment: ""))
        usernameTextField.placeholder = NSLocalizedString("sign_up_username_field_hint", comment: "")
        emailTextField.placeholder = NSLocalizedString("sign_up_email_field_hint", comment: "")
        passwordTextField.placeholder = NSLocalizedString("sign_up_password_field_hint", comment: "")
        signUpButton.setTitle(NSLocalizedString("sign_up_send_button", comment: ""), forState: .Normal)
        
        usernameTextField.tintColor = StyleHelper.textFieldTintColor
        emailTextField.tintColor = StyleHelper.textFieldTintColor
        passwordTextField.tintColor = StyleHelper.textFieldTintColor

        // Tags
        usernameTextField.tag = TextFieldTag.Username.rawValue
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }

    // MARK: > Helper
    
    private func updateViewModelText(text: String, fromTextFieldTag tag: Int) {
        if let tag = TextFieldTag(rawValue: tag) {
            switch (tag) {
            case .Username:
                viewModel.username = text
            case .Email:
                viewModel.email = text
            case .Password:
                viewModel.password = text
            }
        }
    }
}
