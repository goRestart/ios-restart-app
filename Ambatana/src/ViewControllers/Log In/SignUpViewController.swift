//
//  SignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class SignUpViewController: BaseViewController, UITextFieldDelegate, SignUpViewModelDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000, Username, Password
    }
    
    // ViewModel
    var viewModel: SignUpViewModel!
    
    // UI
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameButton: UIButton!

    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: SignUpViewModel(), nibName: "SignUpViewController")
    }
    
    required init(viewModel: SignUpViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
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
        emailButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        usernameButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }
    
    // MARK: - Actions
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func usernameButtonPressed(sender: AnyObject) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        viewModel.signUp()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tag = TextFieldTag(rawValue: textField.tag) {
            let iconImageView: UIImageView
            switch (tag) {
            case .Email:
                iconImageView = emailIconImageView
            case .Username:
                iconImageView = usernameIconImageView
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
            case .Username:
                iconImageView = usernameIconImageView
            case .Password:
                iconImageView = passwordIconImageView
            }
            iconImageView.highlighted = false
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        setText("", intoTextField: textField)
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        if let actualNextView = nextView {
            actualNextView.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        setText(text, intoTextField: textField)
        return false
    }
    
    // MARK: > SignUpViewModelDelegate

    func viewModel(viewModel: SignUpViewModel, updateSendButtonEnabledState enabled: Bool) {
        signUpButton.enabled = enabled
    }
    
    func viewModelDidStartSigningUp(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }
    
    func viewModel(viewModel: SignUpViewModel, didFinishSigningUpWithResult result: SignUpViewModel.Result) {
        
        var completion: (() -> Void)? = nil
        
        switch (result) {
        case .Success:
            break
        case .Error(let errorCode):
            let message: String
            switch (errorCode) {
                case .InvalidEmail:
                    message = NSLocalizedString("sign_up_error_invalid_email", comment: "")
                case .InvalidUsername:
                    message = NSLocalizedString("sign_up_error_invalid_username", comment: "")
                case .InvalidPassword:
                    message = NSLocalizedString("sign_up_error_invalid_password", comment: "")
                case .ConnectionFailed:
                    message = NSLocalizedString("error_connection_failed", comment: "")
                case .EmailTaken:
                    message = NSLocalizedString("sign_up_error_email_taken", comment: "")
                case .InternalError:
                    message = NSLocalizedString("sign_up_error_generic_error", comment: "")
            }
            completion = {
                self.showAutoFadingOutMessageAlert(message)
            }
        }
        
        dismissLoadingMessageAlert(completion: completion)
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popViewController")
        navigationItem.leftBarButtonItem = backButton
//        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        title = NSLocalizedString("sign_up_title", comment: "")
        
        // Appearance
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        signUpButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        signUpButton.layer.cornerRadius = 4
        
        // i18n
        emailTextField.placeholder = NSLocalizedString("sign_up_email_field_placeholder", comment: "")
        usernameTextField.placeholder = NSLocalizedString("sign_up_username_field_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("sign_up_password_field_placeholder", comment: "")
        signUpButton.setTitle(NSLocalizedString("sign_up_send_button", comment: ""), forState: .Normal)
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        usernameTextField.tag = TextFieldTag.Username.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }
    
    private func setText(text: String, intoTextField textField: UITextField) {
        textField.text = text
        
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .Email:
                viewModel.email = text
            case .Username:
                viewModel.username = text
            case .Password:
                viewModel.password = text
            }
        }
    }
    
    // MARK: > Navigation
    
    func popViewController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        navigationController?.view.layer.addAnimation(transition, forKey: nil)
        navigationController?.popViewControllerAnimated(false)
    }
}
