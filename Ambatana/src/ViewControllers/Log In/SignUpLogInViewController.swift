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
    
    private var helpButton: UIBarButtonItem!

    private let disposeBag: DisposeBag

    
    // Constants & enum

    private static let termsConditionsShownHeight: CGFloat = 118
    
    enum TextFieldTag: Int {
        case Email = 1000, Password, Username
    }
    
    // Data
    var afterLoginAction: (() -> Void)?
    var preDismissAction: (() -> Void)?
    
    var viewModel : SignUpLogInViewModel
    let appearance: LoginAppearance
    let keyboardFocus: Bool
    
    var lines: [CALayer]

    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpLogInViewModel, appearance: LoginAppearance = .Light, keyboardFocus: Bool = false) {
        self.viewModel = viewModel
        self.appearance = appearance
        self.keyboardFocus = keyboardFocus
        self.lines = []
        self.disposeBag = DisposeBag()

        let statusBarStyle: UIStatusBarStyle
        let navBarBackgroundStyle: NavBarBackgroundStyle
        switch appearance {
        case .Dark:
            statusBarStyle = .LightContent
            navBarBackgroundStyle = .Transparent(substyle: .Dark)
        case .Light:
            statusBarStyle = .Default
            navBarBackgroundStyle = .Transparent(substyle: .Light)
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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func viewWillFirstAppear(animated: Bool) {
        super.viewWillFirstAppear(animated)
        if keyboardFocus {
            UIView.performWithoutAnimation { [weak self] in self?.emailTextField.becomeFirstResponder() }
        }
        switch appearance {
        case .Light:
            break
        case .Dark:
            setupKenBurns()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let textFieldLineColor: UIColor
        let dividerColor: UIColor
        switch appearance {
        case .Dark:
            textFieldLineColor = UIColor.black
            dividerColor = UIColor.white
        case .Light:
            textFieldLineColor = UIColor.white
            dividerColor = UIColor.black
        }

        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        dividerViews.forEach { lines.append($0.addBottomBorderWithWidth(1, color: dividerColor)) }

        if viewModel.currentActionType == .Signup {
            lines.append(passwordButton.addTopBorderWithWidth(1, color: textFieldLineColor))
            lines.append(usernameButton.addTopBorderWithWidth(1, color: textFieldLineColor))
        } else if viewModel.currentActionType == .Login {
            lines.append(passwordButton.addTopBorderWithWidth(1, color: textFieldLineColor))
        } else {
            lines.append(emailButton.addTopBorderWithWidth(1, color: textFieldLineColor))
            lines.append(emailButton.addBottomBorderWithWidth(1, color: textFieldLineColor))
        }

        // Redraw masked rounded corners
        emailButton.setRoundedCorners([.TopLeft, .TopRight],
                                      cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        switch viewModel.currentActionType {
        case .Signup:
            passwordButton.setRoundedCorners([], cornerRadius: 0)
        case .Login:
            passwordButton.setRoundedCorners([.BottomLeft, .BottomRight],
                                             cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        }
        usernameButton.setRoundedCorners([.BottomLeft, .BottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
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

        updateUI()
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
    
    @IBAction func connectWithGoogleButtonPressed(sender: AnyObject) {
        viewModel.logInWithGoogle()
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        
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
        let vc = RememberPasswordViewController(source: viewModel.loginSource, email: viewModel.email,
                                                appearance: appearance)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func helpButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func closeButtonPressed() {
        if isRootViewController() {
            dismissViewControllerAnimated(true, completion: nil)
        }
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
            return false
        }
        else {            
            switch (viewModel.currentActionType) {
            case .Signup:
                viewModel.signUp()
            case .Login:
                viewModel.logIn()
            }
            return true
        }
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        guard !string.hasEmojis() else { return false }
        guard let text = textField.text else { return false }
        let newLength = text.characters.count + string.characters.count - range.length
        let removing = text.characters.count > newLength
        if textField === usernameTextField && !removing && newLength > Constants.maxUserNameLength { return false }

        let updatedText = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        updateViewModelText(updatedText, fromTextFieldTag: textField.tag)
        return true
    }
    
    
    // MARK: - UITextViewDelegate
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }


    // MARK: Private Methods

    private func setupCommonUI() {
        view.backgroundColor = UIColor.white
        
        // i18n
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpSignUpButton, forSegmentAtIndex: 0)
        loginSegmentedControl.setTitle(LGLocalizedString.mainSignUpLogInLabel, forSegmentAtIndex: 1)
        loginSegmentedControl.layer.cornerRadius = 15
        loginSegmentedControl.layer.borderWidth = 1
        loginSegmentedControl.layer.masksToBounds = true

        newsletterLabel.text = LGLocalizedString.signUpNewsleter
        newsletterLabel.textColor = UIColor.grayText
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        orLabel.font = UIFont.smallBodyFont
        forgotPasswordButton.setTitle(LGLocalizedString.logInResetPasswordButton, forState: .Normal)

        emailTextField.clearButtonOffset = 0
        emailTextField.text = viewModel.email
        passwordTextField.clearButtonOffset = 0
        usernameTextField.clearButtonOffset = 0

        termsConditionsText.attributedText = viewModel.attributedLegalText(UIColor.grayText)
        termsConditionsText.delegate = self

        // tags
        emailTextField.tag = TextFieldTag.Email.rawValue
        passwordTextField.tag = TextFieldTag.Password.rawValue
        usernameTextField.tag = TextFieldTag.Username.rawValue

        // common appearance
        connectFBButton.setStyle(.Facebook)
        connectGoogleButton.setStyle(.Google)

        sendButton.setStyle(.Primary(fontSize: .Medium))
        sendButton.enabled = false

        showPasswordButton.setImage(UIImage(named: "ic_show_password_inactive"), forState: .Normal)

        if isRootViewController() {
            let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain, target: self,
                action: #selector(SignUpLogInViewController.closeButtonPressed))
            navigationItem.leftBarButtonItem = closeButton
        }

        helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .Plain, target: self,
            action: #selector(SignUpLogInViewController.helpButtonPressed))
        navigationItem.rightBarButtonItem = helpButton
    }

    private func setupUI() {
        setupCommonUI()
        updateUI()

        switch appearance {
        case .Light:
            setupLightAppearance()
        case .Dark:
            setupDarkAppearance()
        }

        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }

        // action type
        loginSegmentedControl.selectedSegmentIndex = viewModel.currentActionType.rawValue

        textFieldsView.clipsToBounds = true
        emailButton.hidden = false
        emailIconImageView.hidden = false
        emailTextField.hidden = false

        showPasswordButton.hidden = !(viewModel.showPasswordVisible)
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
            }.bindTo(connectFBButton.rx_title)
            .addDisposableTo(disposeBag)

        // Google button title
        viewModel.previousGoogleUsername.asObservable()
            .map { username in
                if let username = username {
                    return LGLocalizedString.mainSignUpGoogleConnectButtonWName(username)
                } else {
                    return LGLocalizedString.mainSignUpGoogleConnectButton
                }
            }.bindTo(connectGoogleButton.rx_title)
            .addDisposableTo(disposeBag)
    }

    private func updateUI() {
        let isSignup = viewModel.currentActionType == .Signup
        if isSignup {
            setupSignupUI()
        } else {
            setupLoginUI()
        }

        let sendButtonTitle = isSignup ? LGLocalizedString.signUpSendButton : LGLocalizedString.logInSendButton
        sendButton.setTitle(sendButtonTitle, forState: .Normal)

        let navBarTitle = isSignup ? LGLocalizedString.signUpTitle : LGLocalizedString.logInTitle
        setNavBarTitle(navBarTitle)
    }

    private func setupLightAppearance() {
        darkAppereanceBgView.hidden = true

        loginSegmentedControl.tintColor = UIColor.primaryColor
        loginSegmentedControl.backgroundColor = UIColor.white
        loginSegmentedControl.layer.borderColor = UIColor.primaryColor.CGColor

        let textfieldTextColor = UIColor.blackText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.blackTextHighAlpha

        orLabel.textColor = UIColor.darkGrayText
        lines.forEach { $0.backgroundColor = UIColor.darkGrayText.CGColor }

        emailButton.setStyle(.LightField)
        emailIconImageView.image = UIImage(named: "ic_email")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        passwordButton.setStyle(.LightField)
        passwordIconImageView.image = UIImage(named: "ic_password")
        passwordIconImageView.highlightedImage = UIImage(named: "ic_password_active")
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        usernameButton.setStyle(.LightField)
        usernameIconImageView.image = UIImage(named: "ic_name")
        usernameIconImageView.highlightedImage = UIImage(named: "ic_name_active")
        usernameTextField.textColor = textfieldTextColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpUsernameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        termsConditionsText.tintColor = UIColor.primaryColor

        forgotPasswordButton.setTitleColor(UIColor.darkGrayText, forState: .Normal)
    }

    private func setupDarkAppearance() {
        darkAppereanceBgView.hidden = false

        loginSegmentedControl.tintColor = UIColor.white
        loginSegmentedControl.backgroundColor = UIColor.clearColor()
        loginSegmentedControl.layer.borderColor = UIColor.white.CGColor

        let textfieldTextColor = UIColor.whiteText
        var textfieldPlaceholderAttrs = [String: AnyObject]()
        textfieldPlaceholderAttrs[NSFontAttributeName] = UIFont.systemFontOfSize(17)
        textfieldPlaceholderAttrs[NSForegroundColorAttributeName] = UIColor.whiteTextHighAlpha

        orLabel.textColor = UIColor.white
        lines.forEach { $0.backgroundColor = UIColor.white.CGColor }

        emailButton.setStyle(.DarkField)
        emailIconImageView.image = UIImage(named: "ic_email_dark")
        emailIconImageView.highlightedImage = UIImage(named: "ic_email_active_dark")
        emailTextField.textColor = textfieldTextColor
        emailTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpEmailFieldHint,
                                                                  attributes: textfieldPlaceholderAttrs)
        passwordButton.setStyle(.DarkField)
        passwordIconImageView.image = UIImage(named: "ic_password_dark")
        passwordIconImageView.highlightedImage = UIImage(named: "ic_password_active_dark")
        passwordTextField.textColor = textfieldTextColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpPasswordFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        usernameButton.setStyle(.DarkField)
        usernameIconImageView.image = UIImage(named: "ic_name_dark")
        usernameIconImageView.highlightedImage = UIImage(named: "ic_name_active_dark")
        usernameTextField.textColor = textfieldTextColor
        usernameTextField.attributedPlaceholder = NSAttributedString(string: LGLocalizedString.signUpUsernameFieldHint,
                                                                     attributes: textfieldPlaceholderAttrs)
        termsConditionsText.tintColor = UIColor.white

        forgotPasswordButton.setTitleColor(UIColor.white, forState: .Normal)
    }

    func setupKenBurns() {
        let images: [UIImage] = [
            UIImage(named: "bg_1_new"),
            UIImage(named: "bg_2_new"),
            UIImage(named: "bg_3_new"),
            UIImage(named: "bg_4_new")
        ].flatMap { return $0}
        view.layoutIfNeeded()
        kenBurnsView.animateWithImages(images, transitionDuration: 10, initialDelay: 0, loop: true, isLandscape: true)
    }

    private func setupSignupUI() {
        passwordButton.setRoundedCorners([], cornerRadius: 0)
        passwordTextField.returnKeyType = .Next
        usernameButton.setRoundedCorners([.BottomLeft, .BottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        usernameButton.hidden = false
        usernameIconImageView.hidden = false
        usernameTextField.hidden = false
        forgotPasswordButton.hidden = true

        termsConditionsContainerHeight.constant = viewModel.termsAndConditionsEnabled ?
            SignUpLogInViewController.termsConditionsShownHeight : 0
        termsConditionsContainer.hidden = !viewModel.termsAndConditionsEnabled

        sendButton.hidden = false
    }

    private func setupLoginUI() {
        passwordButton.setRoundedCorners([.BottomLeft, .BottomRight],
                                         cornerRadius: LGUIKitConstants.textfieldCornerRadius)
        passwordTextField.returnKeyType = .Send
        usernameButton.hidden = true
        usernameIconImageView.hidden = true
        usernameTextField.hidden = true
        forgotPasswordButton.hidden = false

        termsConditionsContainerHeight.constant = 0
        termsConditionsContainer.hidden = true

        sendButton.hidden = false
    }

    private func adaptConstraintsToiPhone4() {
        orLabelTopConstraint.constant = 20
        orLabelBottomConstraint.constant = 20
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


// MARK: - SignUpLogInViewModelDelegate

extension SignUpLogInViewController: SignUpLogInViewModelDelegate {

    func vmUpdateSendButtonEnabledState(enabled: Bool) {
        sendButton.enabled = enabled
    }

    func vmUpdateShowPasswordVisible(visible: Bool) {
        showPasswordButton.hidden = !visible
    }

    func vmFinish(completedAccess completed: Bool) {
        if completed {
            preDismissAction?()
        }
        dismissViewControllerAnimated(true, completion: completed ? afterLoginAction : nil)
    }

    func vmFinishAndShowScammerAlert(contactUrl: NSURL, network: EventParameterAccountNetwork, tracker: Tracker) {
        let parentController = presentingViewController
        let contact = UIAction(
            interface: .Button(LGLocalizedString.loginScammerAlertContactButton, .Primary(fontSize: .Medium)),
            action: {
                tracker.trackEvent(TrackerEvent.loginBlockedAccountContactUs(network))
                parentController?.openInternalUrl(contactUrl)
        })
        let keepBrowsing = UIAction(
            interface: .Button(LGLocalizedString.loginScammerAlertKeepBrowsingButton, .Secondary(fontSize: .Medium, withBorder: false)),
            action: {
                tracker.trackEvent(TrackerEvent.loginBlockedAccountKeepBrowsing(network))
        })
        dismissViewControllerAnimated(false) {
            tracker.trackEvent(TrackerEvent.loginBlockedAccountStart(network))
            parentController?.showAlertWithTitle(LGLocalizedString.loginScammerAlertTitle,
                                                 text: LGLocalizedString.loginScammerAlertMessage,
                                                 alertType: .IconAlert(icon: UIImage(named: "ic_moderation_alert")),
                                                 buttonsLayout: .Vertical, actions:  [contact, keepBrowsing])
        }
    }

    func vmShowRecaptcha(viewModel: RecaptchaViewModel) {
        viewModel.navigator = self

        let snapshot: UIImage? = viewModel.transparentMode ? presentingViewController?.view.takeSnapshot() : nil
        let vc = RecaptchaViewController(viewModel: viewModel, backgroundImage: snapshot)
        if viewModel.transparentMode {
            vc.modalTransitionStyle = .CrossDissolve
        }
        presentViewController(vc, animated: true, completion: nil)
    }

    func vmShowHiddenPasswordAlert() {
        let alertController = UIAlertController(title: "🔑", message: "Speak friend and enter", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        let loginAction = UIAlertAction(title: "Login", style: .Default) { [weak self] _ in
            let passwordTextField = alertController.textFields![0] as UITextField
            self?.viewModel.godLogIn(passwordTextField.text ?? "")
        }
        alertController.addAction(loginAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}


// MARK: - Recaptcha navigator

extension SignUpLogInViewController: RecaptchaNavigator {
    func recaptchaClose() {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func recaptchaFinishedWithToken(token: String) {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        viewModel.recaptchaTokenObtained(token)
    }
}


// MARK: - Accesibility ids

extension SignUpLogInViewController {
    func setAccessibilityIds() {
        connectFBButton.accessibilityId = .SignUpLoginFacebookButton
        connectGoogleButton.accessibilityId = .SignUpLoginGoogleButton
        emailButton.accessibilityId = .SignUpLoginEmailButton
        emailTextField.accessibilityId = .SignUpLoginEmailTextField
        passwordButton.accessibilityId = .SignUpLoginPasswordButton
        passwordTextField.accessibilityId = .SignUpLoginEmailTextField
        usernameButton.accessibilityId = .SignUpLoginUserNameButton
        usernameTextField.accessibilityId = .SignUpLoginUserNameTextField
        showPasswordButton.accessibilityId = .SignUpLoginShowPasswordButton
        forgotPasswordButton.accessibilityId = .SignUpLoginForgotPasswordButton
        loginSegmentedControl.accessibilityId = .SignUpLoginSegmentedControl
        helpButton.accessibilityId = .SignUpLoginHelpButton
        navigationItem.leftBarButtonItem?.accessibilityId = .SignUpLoginCloseButton
        sendButton.accessibilityId = .SignUpLoginSendButton
    }
}
