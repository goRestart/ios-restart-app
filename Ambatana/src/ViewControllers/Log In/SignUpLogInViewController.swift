//
//  SignUpLogInViewController.swift
//  LetGo
//
//  Created by Dídac on 18/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import JBKenBurnsView
import RxSwift
import UIKit

class SignUpLogInViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var darkAppereanceBgView: UIView!
    @IBOutlet weak var kenBurnsView: JBKenBurnsView!
    
    @IBOutlet weak var loginSegmentedControl: UISegmentedControl!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var textFieldsView: UIView!

    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectGoogleButton: UIButton!
    
    @IBOutlet var dividerViews: [UIView]!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var orLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var orLabelBottomConstraint: NSLayoutConstraint!

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
    
    fileprivate var helpButton: UIBarButtonItem!

    private let disposeBag: DisposeBag

    
    // Constants & enum

    private static let termsConditionsShownHeight: CGFloat = 118
    
    enum TextFieldTag: Int {
        case email = 1000, password, username
    }
    
    // Data
    var afterLoginAction: (() -> Void)? //really means: postSuccessDismissAction
    var preDismissAction: (() -> Void)? //really means: preSuccessDismissAction
    var willCloseAction: (() -> Void)?  //but not on success just close button.
    
    var viewModel : SignUpLogInViewModel
    let appearance: LoginAppearance
    let keyboardFocus: Bool
    
    var lines: [CALayer]

    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpLogInViewModel, appearance: LoginAppearance = .light, keyboardFocus: Bool = false) {
        self.viewModel = viewModel
        self.appearance = appearance
        self.keyboardFocus = keyboardFocus
        self.lines = []
        self.disposeBag = DisposeBag()

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .dark:
            statusBarStyle = .lightContent
            navBarBackgroundStyle = .transparent(substyle: .dark)
        case .light:
            statusBarStyle = .default
            navBarBackgroundStyle = .transparent(substyle: .light)
        }
        super.init(viewModel: viewModel, nibName: "SignUpLogInViewController",
                   statusBarStyle: statusBarStyle, navBarBackgroundStyle: navBarBackgroundStyle)
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
        setAccessibilityIds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func viewWillFirstAppear(_ animated: Bool) {
        super.viewWillFirstAppear(animated)
        if keyboardFocus {
            UIView.performWithoutAnimation { [weak self] in self?.emailTextField.becomeFirstResponder() }
        }
        switch appearance {
        case .light:
            break
        case .dark:
            setupKenBurns()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let textFieldLineColor: UIColor
        let dividerColor: UIColor
        switch appearance {
        case .dark:
            textFieldLineColor = UIColor.black
            dividerColor = UIColor.white
        case .light:
            textFieldLineColor = UIColor.white
            dividerColor = UIColor.black
        }

        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        dividerViews.forEach { lines.append($0.addBottomBorderWithWidth(1, color: dividerColor)) }

        if viewModel.currentActionType == .signup {
            lines.append(passwordButton.addTopBorderWithWidth(1, color: textFieldLineColor))
            lines.append(usernameButton.addTopBorderWithWidth(1, color: textFieldLineColor))
        } else if viewModel.currentActionType == .login {
            lines.append(passwordButton.addTopBorderWithWidth(1, color: textFieldLineColor))
        } else {
            lines.append(emailButton.addTopBorderWithWidth(1, color: textFieldLineColor))
            lines.append(emailButton.addBottomBorderWithWidth(1, color: textFieldLineColor))
        }

        // Redraw masked rounded corners
        emailButton.setRoundedCorners([.topLeft, .topRight],
                                      cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        switch viewModel.currentActionType {
        case .signup:
            passwordButton.setRoundedCorners([], cornerRadius: 0)
        case .login:
            passwordButton.setRoundedCorners([.bottomLeft, .bottomRight],
                                             cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        }
        usernameButton.setRoundedCorners([.bottomLeft, .bottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
    }


    // MARK: - Actions & public methods

    @IBAction func loginSegmentedControlChangedValue(_ sender: AnyObject) {
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
        viewModel.currentActionType = LoginActionType(rawValue: segment.selectedSegmentIndex) ?? .login
        
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: false)

        updateUI()
    }
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        if sender == termsConditionsSwitch {
            viewModel.termsAccepted = sender.isOn
        } else if sender == newsletterSwitch {
            viewModel.newsletterAccepted = sender.isOn
        }
    }
    
    @IBAction func connectWithFacebookButtonPressed(_ sender: AnyObject) {
        viewModel.logInWithFacebook()
    }
    
    @IBAction func connectWithGoogleButtonPressed(_ sender: AnyObject) {
        viewModel.logInWithGoogle()
    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        
        switch (viewModel.currentActionType) {
        case .signup:
            viewModel.signUp()
        case .login:
            viewModel.logIn()
        }
    }
    
    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordButtonPressed(_ sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: AnyObject) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry

        let imgButton = passwordTextField.isSecureTextEntry ?
            UIImage(named: "ic_show_password_inactive") : UIImage(named: "ic_show_password")
        showPasswordButton.setImage(imgButton, for: .normal)

        // TODO: ⚠️ i should apply this in new vc
        // workaround to avoid weird font type
        passwordTextField.font = UIFont(name: "systemFont", size: 17)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
            attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17) ])
       
    }
    
    @IBAction func usernameButtonPressed(_ sender: AnyObject) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: AnyObject) {
        viewModel.openRememberPassword()
    }

    func closeButtonPressed() {
        viewModel.cancel()
    }

    func helpButtonPressed() {
        viewModel.openHelp()
    }


    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textFieldsView.frame.origin.y+emailTextField.frame.origin.y),
                                        animated: true)

        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
        let iconImageView: UIImageView
        switch (tag) {
        case .email:
            iconImageView = emailIconImageView
        case .password:
            iconImageView = passwordIconImageView
        case .username:
            iconImageView = usernameIconImageView
        }
        iconImageView.isHighlighted = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let tag = TextFieldTag(rawValue: textField.tag) else { return }
        
        let iconImageView: UIImageView
        switch (tag) {
        case .username:
            iconImageView = usernameIconImageView
        case .email:
            iconImageView = emailIconImageView
        case .password:
            iconImageView = passwordIconImageView
        }
        iconImageView.isHighlighted = false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        updateViewModelText("", fromTextFieldTag: textField.tag)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let nextView = view.viewWithTag(tag + 1)
        
        if textField.returnKeyType == .next {
            guard let actualNextView = nextView else { return true }
            actualNextView.becomeFirstResponder()
            return false
        }
        else {            
            switch (viewModel.currentActionType) {
            case .signup:
                viewModel.signUp()
            case .login:
                viewModel.logIn()
            }
            return true
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard !string.hasEmojis() else { return false }
        guard let text = textField.text else { return false }
        let newLength = text.characters.count + string.characters.count - range.length
        let removing = text.characters.count > newLength
        if textField === usernameTextField && !removing && newLength > Constants.maxUserNameLength { return false }

        let updatedText = (text as NSString).replacingCharacters(in: range, with: string)
        updateViewModelText(updatedText, fromTextFieldTag: textField.tag)
        return true
    }
    
    
    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        viewModel.open(url: url)
        return false
    }


    // MARK: Private Methods

    private func setupCommonUI() {
        view.backgroundColor = UIColor.white
        
        // i18n
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpSignUpButton, forSegmentAt: 0)
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpLogInLabel, forSegmentAt: 1)
        loginSegmentedControl.layer.cornerRadius = 15
        loginSegmentedControl.layer.borderWidth = 1
        loginSegmentedControl.layer.masksToBounds = true

        newsletterLabel.text = LGLocalizedString.signUpNewsleter
        newsletterLabel.textColor = UIColor.grayText
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        orLabel.font = UIFont.smallBodyFont
        forgotPasswordButton.setTitle(LGLocalizedString.logInResetPasswordButton, for: .normal)

        emailTextField.clearButtonOffset = 0
        emailTextField.text = viewModel.email
        passwordTextField.clearButtonOffset = 0
        usernameTextField.clearButtonOffset = 0

        termsConditionsText.attributedText = viewModel.attributedLegalText(UIColor.grayText)
        termsConditionsText.delegate = self

        // tags
        emailTextField.tag = TextFieldTag.email.rawValue
        passwordTextField.tag = TextFieldTag.password.rawValue
        usernameTextField.tag = TextFieldTag.username.rawValue

        // common appearance
        connectFBButton.setStyle(.facebook)
        connectGoogleButton.setStyle(.google)

        sendButton.setStyle(.primary(fontSize: .medium))
        sendButton.isEnabled = false

        showPasswordButton.setImage(UIImage(named: "ic_show_password_inactive"), for: .normal)

        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain, target: self,
                action: #selector(SignUpLogInViewController.closeButtonPressed))
            navigationItem.leftBarButtonItem = closeButton
        }

        helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .plain, target: self,
            action: #selector(SignUpLogInViewController.helpButtonPressed))
        navigationItem.rightBarButtonItem = helpButton
    }

    private func setupUI() {
        setupCommonUI()
        updateUI()

        switch appearance {
        case .light:
            setupLightAppearance()
        case .dark:
            setupDarkAppearance()
        }

        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }

        // action type
        loginSegmentedControl.selectedSegmentIndex = viewModel.currentActionType.rawValue

        textFieldsView.clipsToBounds = true
        emailButton.isHidden = false
        emailIconImageView.isHidden = false
        emailTextField.isHidden = false

        showPasswordButton.isHidden = !(viewModel.showPasswordVisible)
    }

    private func setupRx() {
        // Facebook button title
        viewModel.previousFacebookUsername.asObservable()
            .map { username in
                if let username = username {
                    return LGLocalizedString.mainSignUpFacebookConnectButtonWName(username)
                } else {
                    return LGLocalizedString.mainSignUpFacebookConnectButton
                }
            }.bindTo(connectFBButton.rx.title)
            .addDisposableTo(disposeBag)

        // Google button title
        viewModel.previousGoogleUsername.asObservable()
            .map { username in
                if let username = username {
                    return LGLocalizedString.mainSignUpGoogleConnectButtonWName(username)
                } else {
                    return LGLocalizedString.mainSignUpGoogleConnectButton
                }
            }.bindTo(connectGoogleButton.rx.title)
            .addDisposableTo(disposeBag)
    }

    private func updateUI() {
        let isSignup = viewModel.currentActionType == .signup
        if isSignup {
            setupSignupUI()
        } else {
            setupLoginUI()
        }

        let sendButtonTitle = isSignup ? LGLocalizedString.signUpSendButton : LGLocalizedString.logInSendButton
        sendButton.setTitle(sendButtonTitle, for: .normal)

        let navBarTitle = isSignup ? LGLocalizedString.signUpTitle : LGLocalizedString.logInTitle
        setNavBarTitle(navBarTitle)
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.isHidden = true

        loginSegmentedControl.tintColor = UIColor.primaryColor
        loginSegmentedControl.backgroundColor = UIColor.white
        loginSegmentedControl.layer.borderColor = UIColor.primaryColor.cgColor

        let textfieldTextColor = UIColor.blackText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha

        orLabel.textColor = UIColor.darkGrayText
        lines.forEach { $0.backgroundColor = UIColor.darkGrayText.cgColor }

        emailButton.setStyle(.lightField)
        emailIconImageView.image = UIImage(named: "ic_email")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        passwordButton.setStyle(.lightField)
        passwordIconImageView.image = UIImage(named: "ic_password")
        passwordIconImageView.highlightedImage = UIImage(named: "ic_password_active")
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        usernameButton.setStyle(.lightField)
        usernameIconImageView.image = UIImage(named: "ic_name")
        usernameIconImageView.highlightedImage = UIImage(named: "ic_name_active")
        usernameTextField.textColor = textfieldTextColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpUsernameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        termsConditionsText.tintColor = UIColor.primaryColor

        forgotPasswordButton.setTitleColor(UIColor.darkGrayText, for: .normal)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.isHidden = false

        loginSegmentedControl.tintColor = UIColor.white
        loginSegmentedControl.backgroundColor = UIColor.clear
        loginSegmentedControl.layer.borderColor = UIColor.white.cgColor

        let textfieldTextColor = UIColor.whiteText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFont(ofSize: 17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.whiteTextHighAlpha

        orLabel.textColor = UIColor.white
        lines.forEach { $0.backgroundColor = UIColor.white.cgColor }

        emailButton.setStyle(.darkField)
        emailIconImageView.image = UIImage(named: "ic_email_dark")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active_dark")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        passwordButton.setStyle(.darkField)
        passwordIconImageView.image = UIImage(named: "ic_password_dark")
        passwordIconImageView.highlightedImage = UIImage(named: "ic_password_active_dark")
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        usernameButton.setStyle(.darkField)
        usernameIconImageView.image = UIImage(named: "ic_name_dark")
        usernameIconImageView.highlightedImage = UIImage(named: "ic_name_active_dark")
        usernameTextField.textColor = textfieldTextColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpUsernameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        termsConditionsText.tintColor = UIColor.white

        forgotPasswordButton.setTitleColor(UIColor.white, for: .normal)
    }

    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
        ].flatMap { return $0}
        view.layoutIfNeeded()
        kenBurnsView.animate(withImages: images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }

    private func setupSignupUI() {
        passwordButton.setRoundedCorners([], cornerRadius: 0)
        passwordTextField.returnKeyType = .next
        usernameButton.setRoundedCorners([.bottomLeft, .bottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        usernameButton.isHidden = false
        usernameIconImageView.isHidden = false
        usernameTextField.isHidden = false
        forgotPasswordButton.isHidden = true

        termsConditionsContainerHeight.constant = viewModel.termsAndConditionsEnabled ?
            SignUpLogInViewController.termsConditionsShownHeight : 0
        termsConditionsContainer.isHidden = !viewModel.termsAndConditionsEnabled

        sendButton.isHidden = false
    }

    private func setupLoginUI() {
        passwordButton.setRoundedCorners([.bottomLeft, .bottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        passwordTextField.returnKeyType = .send
        usernameButton.isHidden = true
        usernameIconImageView.isHidden = true
        usernameTextField.isHidden = true
        forgotPasswordButton.isHidden = false

        termsConditionsContainerHeight.constant = 0
        termsConditionsContainer.isHidden = true

        sendButton.isHidden = false
    }

    private func adaptConstraintsToiPhone4() {
        orLabelTopConstraint.constant = 20
        orLabelBottomConstraint.constant = 20
    }
    
    private func updateViewModelText(_ text: String, fromTextFieldTag tag: Int) {
        
        guard let tag = TextFieldTag(rawValue: tag) else { return }
        
        switch (tag) {
        case .username:
            viewModel.username = text
        case .email:
            viewModel.email = text
        case .password:
            viewModel.password = text
        }
    }
}


// MARK: - SignUpLogInViewModelDelegate

extension SignUpLogInViewController: SignUpLogInViewModelDelegate {

    func vmUpdateSendButtonEnabledState(_ enabled: Bool) {
        sendButton.isEnabled = enabled
    }

    func vmUpdateShowPasswordVisible(_ visible: Bool) {
        showPasswordButton.isHidden = !visible
    }

    func vmShowHiddenPasswordAlert() {
        let alertController = UIAlertController(title: "🔑", message: "Speak friend and enter", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        let loginAction = UIAlertAction(title: "Login", style: .default) { [weak self] _ in
            guard let passwordTextField = alertController.textFields?.first else { return }
            self?.viewModel.godLogIn(passwordTextField.text ?? "")
        }
        alertController.addAction(loginAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Accesibility ids

extension SignUpLogInViewController {
    func setAccessibilityIds() {
        connectFBButton.accessibilityId = .signUpLoginFacebookButton
        connectGoogleButton.accessibilityId = .signUpLoginGoogleButton
        emailButton.accessibilityId = .signUpLoginEmailButton
        emailTextField.accessibilityId = .signUpLoginEmailTextField
        passwordButton.accessibilityId = .signUpLoginPasswordButton
        passwordTextField.accessibilityId = .signUpLoginEmailTextField
        usernameButton.accessibilityId = .signUpLoginUserNameButton
        usernameTextField.accessibilityId = .signUpLoginUserNameTextField
        showPasswordButton.accessibilityId = .signUpLoginShowPasswordButton
        forgotPasswordButton.accessibilityId = .signUpLoginForgotPasswordButton
        loginSegmentedControl.accessibilityId = .signUpLoginSegmentedControl
        helpButton.accessibilityId = .signUpLoginHelpButton
        navigationItem.leftBarButtonItem?.accessibilityId = .signUpLoginCloseButton
        sendButton.accessibilityId = .signUpLoginSendButton
    }
}
