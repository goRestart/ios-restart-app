//
//  SignUpLogInViewController.swift
//  LetGo
//
//  Created by Dídac on 18/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

public  enum LoginActionType: Int{
    case Signup, Login
}

class SignUpLogInViewController: BaseViewController, UITextFieldDelegate, UIScrollViewDelegate, SignUpLogInViewModelDelegate {

    
    
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

    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    // Constants & enum
    
    enum TextFieldTag: Int {
        case Email = 1000, Password, Username
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    
    var currentActionType : LoginActionType
    
    var viewModel : SignUpLogInViewModel
    
    var lines: [CALayer]
    
    var loginEditModeActive : Bool
    var signupEditModeActive : Bool

    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        self.viewModel = SignUpLogInViewModel(source: source, action: action)
        self.lines = []
        self.currentActionType = action
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
        
        if currentActionType == .Signup && signupEditModeActive {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(usernameButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))

        } else if currentActionType == .Login && loginEditModeActive {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        } else {
            lines.append(emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor))
            lines.append(emailButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginSegmentedControlChangedValue(sender: AnyObject) {
        guard let segment = sender as? UISegmentedControl else {
            return
        }
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        currentActionType = LoginActionType(rawValue: segment.selectedSegmentIndex)!
        setupUI()
    }
    
    @IBAction func connectWithFacebookButtonPressed(sender: AnyObject) {
    }
    

    @IBAction func sendButtonPressed(sender: AnyObject) {
    }
    
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
        
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()

    }
    
    @IBAction func usernameButtonPressed(sender: AnyObject) {
        usernameTextField.becomeFirstResponder()

    }
    
    @IBAction func forgotPasswordButtonPressed(sender: AnyObject) {
        let vc = RememberPasswordViewController(source: viewModel.loginSource)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - UITxtFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        scrollView.setContentOffset(CGPointMake(0,textFieldsView.frame.origin.y), animated: true)

        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
                
                if currentActionType == .Signup {
                    signupEditModeActive = true
                }
                else {
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
    
    // MARK: - SignUpLogInViewModelDelegate
    
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool) {
    }
    
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult result: UserSignUpServiceResult) {

    }
    
    
    // MARK: Private Methods
    
    private func setupUI() {
        
        // action type
        loginSegmentedControl.selectedSegmentIndex = currentActionType.rawValue

        // i18n
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

        emailButton.hidden = false
        emailIconImageView.hidden = false
        emailTextField.hidden = false

        let isSignup = currentActionType == .Signup
        
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
        
    }
    
    private func setupSignupUI() {
        
        usernameButton.hidden = !signupEditModeActive
        usernameIconImageView.hidden = !signupEditModeActive
        usernameTextField.hidden = !signupEditModeActive

        forgotPasswordButton.hidden = true
        
        passwordButton.hidden = !signupEditModeActive
        passwordIconImageView.hidden = !signupEditModeActive
        passwordTextField.hidden = !signupEditModeActive

        sendButton.hidden = !signupEditModeActive
        
        let scrollOffsetY = signupEditModeActive ? CGPointMake(0, textFieldsView.frame.origin.y) : CGPointMake(0,0)
        scrollView.setContentOffset(scrollOffsetY, animated: signupEditModeActive)
    }

    private func setupLoginUI() {

        usernameButton.hidden = true
        usernameIconImageView.hidden = true
        usernameTextField.hidden = true
        
        forgotPasswordButton.hidden = !loginEditModeActive
        
        passwordButton.hidden = !loginEditModeActive
        passwordIconImageView.hidden = !loginEditModeActive
        passwordTextField.hidden = !loginEditModeActive
        
        sendButton.hidden = !loginEditModeActive
        
        let scrollOffsetY = loginEditModeActive ? CGPointMake(0, textFieldsView.frame.origin.y) : CGPointMake(0,0)
        scrollView.setContentOffset(scrollOffsetY, animated: loginEditModeActive)

    }

}
