//
//  MainSignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class MainSignUpViewController: BaseViewController, SignUpViewModelDelegate, UITextViewDelegate, GIDSignInUIDelegate {

    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: SignUpViewModel
    
    // UI
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var quicklyLabel: UILabel!

    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectGoogleButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    // Footer
    
    @IBOutlet weak var legalTextView: UITextView!
    
    // Constraints to adapt for iPhone4
    @IBOutlet weak var loginButtonBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var orDividerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookButtonTopMarginConstraint: NSLayoutConstraint!
    
    // Bar Buttons
    private var closeButton: UIBarButtonItem?
    private var helpButton: UIBarButtonItem?
    
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        self.lines = []
        super.init(viewModel: viewModel, nibName: "MainSignUpViewController",
                   navBarBackgroundStyle: .Transparent(substyle: .Light))
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setAccesibilityIds()
        
        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(dividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(firstDividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }
    
    // MARK: - Actions
    
    func closeButtonPressed() {
        viewModel.abandon()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func helpButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func connectFBButtonPressed(sender: AnyObject) {
        viewModel.logInWithFacebook()
    }
    
    @IBAction func connectGoogleButtonPressed(sender: AnyObject) {
        viewModel.logInWithGoogle()
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let vc = SignUpLogInViewController(viewModel: viewModel.loginSignupViewModelForSignUp())
        vc.afterLoginAction = afterLoginAction
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logInButtonPressed(sender: AnyObject) {
        let vc = SignUpLogInViewController(viewModel: viewModel.loginSignupViewModelForLogin())
        vc.afterLoginAction = afterLoginAction
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func contactUsButtonPressed() {
        let vc = HelpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - MainSignUpViewModelDelegate
    
    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }

    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: self?.afterLoginAction)
        }
    }

    func viewModeldidCancelLoginIn(viewModel: SignUpViewModel) {
        dismissLoadingMessageAlert()
    }

    func viewModel(viewModel: SignUpViewModel, didFailLoginIn message: String) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(message, time: 3)
        }
    }
    
    
    // MARK: UITextViewDelegate
    
    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }
    
    // MARK: - Private methods
    
    // MARK: > UI
    
    private func setupUI() {

        // View
        view.backgroundColor = UIColor.listBackgroundColor

        // Navigation bar
        closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain, target: self,
            action: #selector(MainSignUpViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .Plain, target: self,
            action: #selector(MainSignUpViewController.helpButtonPressed))
        navigationItem.rightBarButtonItem = helpButton

        // Appearance
        connectFBButton.setStyle(.Facebook)
        connectGoogleButton.setStyle(.Google)

        signUpButton.setStyle(.Secondary(fontSize: .Medium, withBorder: true))
        logInButton.setStyle(.Secondary(fontSize: .Medium, withBorder: true))

        // i18n
        claimLabel.text = LGLocalizedString.mainSignUpClaimLabel
        claimLabel.font = UIFont.smallBodyFont
        claimLabel.textColor = UIColor.black
        quicklyLabel.text = LGLocalizedString.mainSignUpQuicklyLabel
        quicklyLabel.font = UIFont.smallBodyFont
        quicklyLabel.backgroundColor = view.backgroundColor

        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        connectGoogleButton.setTitle(LGLocalizedString.mainSignUpGoogleConnectButton, forState: .Normal)
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        orLabel.font = UIFont.smallBodyFont
        orLabel.backgroundColor = view.backgroundColor
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, forState: .Normal)
        logInButton.setTitle(LGLocalizedString.mainSignUpLogInLabel, forState: .Normal)

        setupTermsAndConditions()
    }
    
    private func adaptConstraintsToiPhone4() {
        loginButtonBottomMarginConstraint.constant = 0
        signUpButtonTopMarginConstraint.constant = 10
        orDividerTopMarginConstraint.constant = 15
        googleButtonTopMarginConstraint.constant = 8
        facebookButtonTopMarginConstraint.constant = 8
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textAlignment = .Center
        legalTextView.delegate = self
    }
}

extension MainSignUpViewController {
    func setAccesibilityIds() {
        connectFBButton.accessibilityId = .MainSignUpFacebookButton
        connectGoogleButton.accessibilityId = .MainSignUpGoogleButton
        signUpButton.accessibilityId = .MainSignUpSignupButton
        logInButton.accessibilityId = .MainSignupLogInButton
        closeButton?.accessibilityId = .MainSignupCloseButton
        helpButton?.accessibilityId = .MainSignupHelpButton
    }
}
