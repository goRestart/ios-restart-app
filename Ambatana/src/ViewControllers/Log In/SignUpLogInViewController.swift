//
//  SignUpLogInViewController.swift
//  LetGo
//
//  Created by Dídac on 18/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

class SignUpLogInViewController: BaseViewController, UITextFieldDelegate, SignUpLogInViewModelDelegate {
    
    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var textFieldsView: UIView!
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var quicklyLabel: UILabel!
    
    @IBOutlet weak var connectFBButton: UIButton!
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: LGTextField!
    @IBOutlet weak var usernameButton: UIButton!
    
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: LGTextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: LGTextField!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    // Constants & enum
    
    enum TextFieldTag: Int {
        case Email = 1000, Password, Username
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    
    var viewModel : SignUpLogInViewModel
    
    var lines: [CALayer]
    
    var loginEditModeActive : Bool
    var signupEditModeActive : Bool

    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        self.viewModel = SignUpLogInViewModel(source: source, action: action)
        self.lines = []
        self.loginEditModeActive = false
        self.signupEditModeActive = false
        super.init(viewModel: viewModel, nibName: "SignUpLogInViewController")
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(dividerView.addBottomBorderWithWidth(1, color: StyleHelper.darkLineColor))
        lines.append(firstDividerView.addBottomBorderWithWidth(1, color: StyleHelper.darkLineColor))
        
        if viewModel.currentActionType == .Signup && signupEditModeActive {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(usernameButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))

        } else if viewModel.currentActionType == .Login && loginEditModeActive {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        } else {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        }
    }


    // MARK: - Actions & public methods

    @IBAction func loginSegmentedControlChangedValue(sender: AnyObject) {
        guard let segment = sender as? UISegmentedControl else {
            return
        }
        viewModel.erasePassword()
        emailTextField.text = viewModel.email
        passwordTextField.text = viewModel.password
        usernameTextField.text = viewModel.username
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        viewModel.currentActionType = LoginActionType(rawValue: segment.selectedSegmentIndex)!
        
        scrollView.setContentOffset(CGPointMake(0,0), animated: false)

        setupUI()
    }
    
    @IBAction func connectWithFacebookButtonPressed(sender: AnyObject) {
        viewModel.logInWithFacebook()
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        switch (viewModel.currentActionType) {
        case .Signup:
            viewModel.signUp()
        case .Login:
            viewModel.logIn()
        }
    }
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func showPasswordButtonPressed(sender: AnyObject) {
        passwordTextField.secureTextEntry = !passwordTextField.secureTextEntry

        let imgButton = passwordTextField.secureTextEntry ? UIImage(named: "ic_show_password_inactive") : UIImage(named: "ic_show_password")
        showPasswordButton.setImage(imgButton, forState: .Normal)
        
        // workaround to avoid weird font type
        passwordTextField.font = UIFont(name: "systemFont", size: 17)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17) ])
       
    }
    
    @IBAction func usernameButtonPressed(sender: AnyObject) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func forgotPasswordButtonPressed(sender: AnyObject) {
        let vc = RememberPasswordViewController(source: viewModel.loginSource, email: viewModel.email)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        scrollView.setContentOffset(CGPointMake(0,textFieldsView.frame.origin.y+textField.frame.origin.y), animated: true)

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
        let iconImageView: UIImageView
        switch (tag) {
        case .Email:
            iconImageView = emailIconImageView
            
            switch (viewModel.currentActionType) {
            case .Signup:
                signupEditModeActive = true
            case .Login:
                loginEditModeActive = true
            }
            
            setupUI()
        case .Password:
            iconImageView = passwordIconImageView
        case .Username:
            iconImageView = usernameIconImageView
        }
        
        iconImageView.highlighted = true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
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
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        
        if textField.returnKeyType == .Next {
            guard let actualNextView = nextView else { return true }
            actualNextView.becomeFirstResponder()
        }
        else {            
            switch (viewModel.currentActionType) {
            case .Signup:
                viewModel.signUp()
            case .Login:
                viewModel.logIn()
            }
        }
        
        return true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        guard let textFieldText = textField.text else { return true }
        
        let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateViewModelText(text, fromTextFieldTag: textField.tag)
        
        return true
    }
    
    // MARK: - SignUpLogInViewModelDelegate
    
    // MARK: > visual
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool) {
        sendButton.enabled = enabled
        sendButton.alpha = enabled ? 1 : StyleHelper.disabledButtonAlpha
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, updateShowPasswordVisible visible: Bool) {
        showPasswordButton.hidden = !visible
    }

    // MARK: > signup
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult result: UserSignUpServiceResult) {
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            let errorDescription : EventParameterLoginError
            let message: String
            switch (error) {
            case .InvalidEmail:
                message = LGLocalizedString.signUpSendErrorInvalidEmail
                errorDescription = .InvalidEmail
            case .InvalidUsername:
                message = String(format: LGLocalizedString.signUpSendErrorInvalidUsername, Constants.fullNameMinLength)
                errorDescription = .InvalidUsername
            case .InvalidPassword:
                message = String(format: LGLocalizedString.signUpSendErrorInvalidPasswordWithMax, Constants.passwordMinLength, Constants.passwordMaxLength)
                errorDescription = .InvalidPassword
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
                errorDescription = .Network
            case .EmailTaken:
                message = String(format: LGLocalizedString.signUpSendErrorEmailTaken, viewModel.email)
                errorDescription = .EmailTaken
            case .UsernameTaken:
                message = String(format: LGLocalizedString.signUpSendErrorInvalidUsernameLetgo, viewModel.username)
                errorDescription = .UsernameTaken
            case .Internal:
                message = LGLocalizedString.signUpSendErrorGeneric
                errorDescription = .Internal
            }
            viewModel.signupFailedWithError(errorDescription)
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: > login
    
    func viewModelDidStartLoggingIn(viewModel: SignUpLogInViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingInWithResult result: UserLogInEmailServiceResult) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            let errorDescription : EventParameterLoginError
            let message: String
            switch (error) {
            case .InvalidEmail:
                message = LGLocalizedString.logInErrorSendErrorInvalidEmail
                errorDescription = .InvalidEmail
            case .InvalidPassword:
                message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
                errorDescription = .InvalidPassword
            case .UserNotFoundOrWrongPassword:
                message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
                errorDescription = .UserNotFoundOrWrongPassword
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
                errorDescription = .Network
            case .Internal:
                message = LGLocalizedString.logInErrorSendErrorGeneric
                errorDescription = .Internal
            case .Forbidden:
                message = LGLocalizedString.logInErrorSendErrorGeneric
                errorDescription = .Forbidden
            }
            viewModel.loginFailedWithError(errorDescription)
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: > fb login
    
    func viewModelDidStartLoggingWithFB(viewModel: SignUpLogInViewModel) {
        showCustomLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingWithFBWithResult result: UserLogInFBResult) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            completion = {
                self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
            }
            break
        case .Failure(let error):
            
            var message: String?
            var errorDescription: EventParameterLoginError?
            
            switch (error) {
            case .Cancelled:
                break
            case .EmailTaken:
                message = LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
                errorDescription = .EmailTaken
            case .InvalidPassword:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .InvalidPassword
            case .PasswordMismatch:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .PasswordMismatch
            case .UsernameTaken:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .UsernameTaken
            case .Forbidden:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .Forbidden
            case .Network:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .Network
            case .Internal:
                message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
                errorDescription = .Internal
            }
            
            if let actualErrorDescription = errorDescription {
                viewModel.loginFailedWithError(actualErrorDescription)
            }
            
            completion = {
                if let actualMessage = message {
                    self.showAutoFadingOutMessageAlert(actualMessage, time: 3)
                }
            }
        }
        dismissCustomLoadingMessageAlert(completion)
    }
    
    // MARK: Private Methods
    
    private func setupUI() {
        
        // action type
        loginSegmentedControl.selectedSegmentIndex = viewModel.currentActionType.rawValue

        // i18n
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpSignUpButton, forSegmentAtIndex: 0)
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpLogInLabel, forSegmentAtIndex: 1)
        usernameTextField.placeholder = LGLocalizedString.signUpUsernameFieldHint
        emailTextField.placeholder = LGLocalizedString.signUpEmailFieldHint
        passwordTextField.placeholder = LGLocalizedString.signUpPasswordFieldHint
        
        quicklyLabel.text = LGLocalizedString.mainSignUpQuicklyLabel
        
        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        
        forgotPasswordButton.setTitle(LGLocalizedString.logInResetPasswordButton, forState: .Normal)
        
        // tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
        usernameTextField.tag = TextFieldTag.Username.rawValue

        // appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        connectFBButton.layer.cornerRadius = 4

        sendButton.setBackgroundImage(sendButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        sendButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        sendButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Highlighted)
        
        sendButton.layer.cornerRadius = 4
        sendButton.enabled = false
        sendButton.alpha = StyleHelper.disabledButtonAlpha

        emailButton.hidden = false
        emailIconImageView.hidden = false
        emailTextField.hidden = false

        showPasswordButton.setImage(UIImage(named: "ic_show_password_inactive"), forState: .Normal)
        showPasswordButton.hidden = !(viewModel.showPasswordShouldBeVisible)
        
        let isSignup = viewModel.currentActionType == .Signup
        
        if isSignup {
            setupSignupUI()
        }
        else {
            setupLoginUI()
        }

        let sendButtonTitle = isSignup ? LGLocalizedString.signUpSendButton : LGLocalizedString.logInSendButton
        sendButton.setTitle(sendButtonTitle, forState: .Normal)
        
        let navBarTitle = isSignup ? LGLocalizedString.signUpTitle : LGLocalizedString.logInTitle
        setLetGoNavigationBarStyle(navBarTitle)
        let helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .Plain, target: self, action: Selector("helpButtonPressed"))
        navigationItem.rightBarButtonItem = helpButton
    }
    
    private func setupSignupUI() {
        
        usernameButton.hidden = !signupEditModeActive
        usernameIconImageView.hidden = !signupEditModeActive
        usernameTextField.hidden = !signupEditModeActive

        forgotPasswordButton.hidden = true
        
        passwordButton.hidden = !signupEditModeActive
        passwordIconImageView.hidden = !signupEditModeActive
        passwordTextField.hidden = !signupEditModeActive

        passwordTextField.returnKeyType = .Next
        
        sendButton.hidden = !signupEditModeActive
        
    }

    private func setupLoginUI() {

        usernameButton.hidden = true
        usernameIconImageView.hidden = true
        usernameTextField.hidden = true
        
        forgotPasswordButton.hidden = !loginEditModeActive
        
        passwordButton.hidden = !loginEditModeActive
        passwordIconImageView.hidden = !loginEditModeActive
        passwordTextField.hidden = !loginEditModeActive
        
        passwordTextField.returnKeyType = .Send

        sendButton.hidden = !loginEditModeActive
        
    }

    
    private func updateViewModelText(text: String, fromTextFieldTag tag: Int) {
        
        guard let tag = TextFieldTag(rawValue: tag) else { return }
        
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
