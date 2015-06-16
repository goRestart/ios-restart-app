//
//  LogInViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class LogInViewController: BaseViewController, UITextFieldDelegate {
    
    // Constants & enum
    enum TextFieldTag: Int {
        case Email = 1000, Password
    }
    
    // ViewModel
    var viewModel: LogInViewModel!
    
    // UI
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    // MARK: - Lifecycle
    
    convenience init() {
        self.init(viewModel: LogInViewModel(), nibName: "LogInViewController")
    }
    
    required init(viewModel: LogInViewModel, nibName nibNameOrNil: String?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: nibNameOrNil)
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
        passwordButton.addTopBorderWithWidth(1, color: StyleHelper.lineColor)
        passwordButton.addBottomBorderWithWidth(1, color: StyleHelper.lineColor)
    }

    // MARK: - Actions
    
    @IBAction func emailButtonPressed(sender: AnyObject) {
    
    }
    
    @IBAction func passwordButtonPressed(sender: AnyObject) {
    
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
    
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
        textField.text = ""
        updateSendButtonEnabledState()
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
        textField.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateSendButtonEnabledState()
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    func setupUI() {
        // Navigation bar
        let backButton = UIBarButtonItem(image: UIImage(named: "navbar_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "popViewController")
        navigationItem.leftBarButtonItem = backButton
//        navigationController?.interactivePopGestureRecognizer.delegate = self as? UIGestureRecognizerDelegate
        
        title = NSLocalizedString("log_in_title", comment: "")
        
        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)), forState: .Normal)
        logInButton.setBackgroundImage(StyleHelper.disabledButtonBackgroundColor.imageWithSize(CGSize(width: 1, height: 1)), forState: .Disabled)
        logInButton.layer.cornerRadius = 4
        
        // i18n
        emailTextField.placeholder = NSLocalizedString("log_in_email_field_placeholder", comment: "")
        passwordTextField.placeholder = NSLocalizedString("log_in_password_field_placeholder", comment: "")
        logInButton.setTitle(NSLocalizedString("log_in_send_button", comment: ""), forState: .Normal)
        
        // Tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
    }
    
    private func updateSendButtonEnabledState() {
        logInButton.enabled = count(emailTextField.text) > 0 && count(passwordTextField.text) > 0
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