//
//  SignUpLogInViewController.swift
//  LetGo
//
//  Created by Dídac on 18/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import Result

class SignUpLogInViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate,
SignUpLogInViewModelDelegate {
    
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
    
    @IBOutlet weak var termsConditionsContainer: UIView!
    @IBOutlet weak var termsConditionsContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var termsConditionsText: UITextView!
    @IBOutlet weak var termsConditionsSwitch: UISwitch!
    @IBOutlet weak var newsletterLabel: UILabel!
    @IBOutlet weak var newsletterSwitch: UISwitch!

    @IBOutlet weak var sendButton: UIButton!
    
    // Constants & enum

    private static let termsConditionsShownHeight: CGFloat = 118
    
    enum TextFieldTag: Int {
        case Email = 1000, Password, Username
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    
    var viewModel : SignUpLogInViewModel
    
    var lines: [CALayer]
    
    var loginEditModeActive: Bool
    var signupEditModeActive: Bool
    var termsConditionsActive: Bool {
        return signupEditModeActive && viewModel.termsAndConditionsEnabled
    }

    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpLogInViewModel) {
        self.viewModel = viewModel
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

        setupStaticUI()
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
    
    @IBAction func onSwitchValueChanged(sender: UISwitch) {
        if sender == termsConditionsSwitch {
            viewModel.termsAccepted = sender.on
        } else if sender == newsletterSwitch {
            viewModel.newsletterAccepted = sender.on
        }
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

        let imgButton = passwordTextField.secureTextEntry ?
            UIImage(named: "ic_show_password_inactive") : UIImage(named: "ic_show_password")
        showPasswordButton.setImage(imgButton, forState: .Normal)
        
        // workaround to avoid weird font type
        passwordTextField.font = UIFont(name: "systemFont", size: 17)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
            attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17) ])
       
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
        
        scrollView.setContentOffset(CGPointMake(0,textFieldsView.frame.origin.y+textField.frame.origin.y),
            animated: true)

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
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            guard let textFieldText = textField.text else { return true }
            
            let text = (textFieldText as NSString).stringByReplacingCharactersInRange(range, withString: string)
            updateViewModelText(text, fromTextFieldTag: textField.tag)
            return true
    }


    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
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
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult
        result: Result<MyUser, SignUpLogInError>) {
            var completion: (() -> Void)? = nil
        
            switch (result) {
            case .Success:
                completion = {
                    self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
                }
                break
            case .Failure(let error):
                let errorDescription : EventParameterLoginError
                var message = LGLocalizedString.signUpSendErrorGeneric
                switch (error) {
                case .InvalidUsername:
                    message = LGLocalizedString.signUpSendErrorInvalidUsername(Constants.fullNameMinLength)
                    errorDescription = .InvalidUsername
                case .InvalidEmail:
                    message = LGLocalizedString.signUpSendErrorInvalidEmail
                    errorDescription = .InvalidEmail
                case .InvalidPassword:
                    message = LGLocalizedString.signUpSendErrorInvalidPasswordWithMax(Constants.passwordMinLength,
                        Constants.passwordMaxLength)
                    errorDescription = .InvalidPassword
                case .TermsNotAccepted:
                    message = LGLocalizedString.signUpAcceptanceError
                    errorDescription = .TermsNotAccepted
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                    errorDescription = .Network
                case .Scammer:
                    errorDescription = .Forbidden
                case .NotFound:
                    errorDescription = .NotFound
                case .AlreadyExists:
                    message = LGLocalizedString.signUpSendErrorEmailTaken(viewModel.email)
                    errorDescription = .EmailTaken
                case .Internal, .UsernameTaken, .Unauthorized:
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
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingInWithResult
        result: Result<MyUser, SignUpLogInError>) {
            var completion: (() -> Void)? = nil
            
            switch (result) {
            case .Success:
                completion = {
                    self.dismissViewControllerAnimated(true, completion: self.afterLoginAction)
                }
                break
            case .Failure(let error):
                let errorDescription : EventParameterLoginError
                var message = LGLocalizedString.logInErrorSendErrorGeneric
                switch (error) {
                case .UsernameTaken:
                    errorDescription = .UsernameTaken
                case .InvalidUsername:
                    errorDescription = .InvalidUsername
                case .InvalidEmail:
                    message = LGLocalizedString.logInErrorSendErrorInvalidEmail
                    errorDescription = .InvalidEmail
                case .InvalidPassword:
                    message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
                    errorDescription = .InvalidPassword
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                    errorDescription = .Network
                case .Unauthorized:
                    errorDescription = .UserNotFoundOrWrongPassword
                    message = LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
                case .Scammer:
                    errorDescription = .Forbidden
                case .NotFound:
                    errorDescription = .NotFound
                case .Internal, .AlreadyExists:
                    errorDescription = .Internal
                case .TermsNotAccepted: //Will never happen
                    errorDescription = .Internal
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
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishLoggingWithFBWithResult result: FBLoginResult) {

        var completion: (() -> Void)? = nil
        var message = LGLocalizedString.mainSignUpFbConnectErrorGeneric
        var errorDescription: EventParameterLoginError?

        switch result {
        case .Success:
            completion = { [weak self] in
                self?.dismissViewControllerAnimated(true, completion: self?.afterLoginAction)
            }
        case .Cancelled:
            break
        case .Network:
            errorDescription = .Network
        case .Forbidden:
            errorDescription = .Forbidden
        case .NotFound:
            errorDescription = .UserNotFoundOrWrongPassword
        case .AlreadyExists:
            message = LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
            errorDescription = .EmailTaken
        case .Internal:
            errorDescription = .Internal
        }

        if let actualErrorDescription = errorDescription {
            viewModel.loginFailedWithError(actualErrorDescription)
            completion = { [weak self] in
                self?.showAutoFadingOutMessageAlert(message, time: 3)
            }
        }
        dismissLoadingMessageAlert(completion)
    }
    
    // MARK: Private Methods

    private func setupStaticUI() {
        // i18n
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpSignUpButton, forSegmentAtIndex: 0)
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpLogInLabel, forSegmentAtIndex: 1)
        usernameTextField.placeholder = LGLocalizedString.signUpUsernameFieldHint
        emailTextField.placeholder = LGLocalizedString.signUpEmailFieldHint
        passwordTextField.placeholder = LGLocalizedString.signUpPasswordFieldHint
        newsletterLabel.text = LGLocalizedString.signUpNewsleter
        quicklyLabel.text = LGLocalizedString.mainSignUpQuicklyLabel
        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        forgotPasswordButton.setTitle(LGLocalizedString.logInResetPasswordButton, forState: .Normal)

        setupTermsConditionsText()

        // tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
        usernameTextField.tag = TextFieldTag.Username.rawValue

        // appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        connectFBButton.layer.cornerRadius = StyleHelper.defaultCornerRadius

        sendButton.setBackgroundImage(sendButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        sendButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(
            CGSize(width: 1, height: 1)), forState: .Disabled)
        sendButton.setBackgroundImage(StyleHelper.highlightedRedButtonColor.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Highlighted)

        sendButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        sendButton.enabled = false
        sendButton.alpha = StyleHelper.disabledButtonAlpha

        showPasswordButton.setImage(UIImage(named: "ic_show_password_inactive"), forState: .Normal)

        let helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .Plain, target: self,
            action: Selector("helpButtonPressed"))
        navigationItem.rightBarButtonItem = helpButton
    }

    private func setupUI() {
        
        // action type
        loginSegmentedControl.selectedSegmentIndex = viewModel.currentActionType.rawValue


        emailButton.hidden = false
        emailIconImageView.hidden = false
        emailTextField.hidden = false

        showPasswordButton.hidden = !(viewModel.showPasswordShouldBeVisible)
        
        let isSignup = viewModel.currentActionType == .Signup
        
        if isSignup {
            setupSignupUI()
        } else {
            setupLoginUI()
        }

        let sendButtonTitle = isSignup ? LGLocalizedString.signUpSendButton : LGLocalizedString.logInSendButton
        sendButton.setTitle(sendButtonTitle, forState: .Normal)
        
        let navBarTitle = isSignup ? LGLocalizedString.signUpTitle : LGLocalizedString.logInTitle
        setLetGoNavigationBarStyle(navBarTitle)
    }

    private func setupTermsConditionsText() {
        guard let conditionsURL = viewModel.termsAndConditionsURL, let privacyURL = viewModel.privacyURL else {
            // Should not happen
            termsConditionsText.text =  LGLocalizedString.signUpTermsConditions
            return
        }

        let links = [LGLocalizedString.signUpTermsConditionsTermsPart: conditionsURL,
            LGLocalizedString.signUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = LGLocalizedString.signUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: UIColor.darkGrayColor())
        attributtedLegalText.addAttribute(NSFontAttributeName, value: StyleHelper.termsConditionsFont,
            range: NSMakeRange(0, attributtedLegalText.length))
        termsConditionsText.attributedText = attributtedLegalText
        termsConditionsText.delegate = self
    }
    
    private func setupSignupUI() {
        usernameButton.hidden = !signupEditModeActive
        usernameIconImageView.hidden = !signupEditModeActive
        usernameTextField.hidden = !signupEditModeActive

        termsConditionsContainerHeight.constant = termsConditionsActive ?
            SignUpLogInViewController.termsConditionsShownHeight : 0
        termsConditionsContainer.hidden = !termsConditionsActive

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

        termsConditionsContainerHeight.constant = 0
        termsConditionsContainer.hidden = true
        
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
