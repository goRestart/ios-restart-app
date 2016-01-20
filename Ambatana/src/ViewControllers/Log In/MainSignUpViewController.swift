//
//  MainSignUpViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

class MainSignUpViewController: BaseViewController, MainSignUpViewModelDelegate, UITextViewDelegate {

    // Data
    var afterLoginAction: (() -> Void)?
    
    // > ViewModel
    var viewModel: MainSignUpViewModel
    
    // > Delegate
    
    // UI
    
    // > Nav Bar
    var navBarBgImage: UIImage!
    var navBarShadowImage: UIImage!

    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var quicklyLabel: UILabel!

    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    
    // Footer
    
    @IBOutlet weak var legalTextView: UITextView!
    
    // > Helper
    var lines: [CALayer]
    
    // MARK: - Lifecycle
    
    init(viewModel: MainSignUpViewModel) {
        self.viewModel = viewModel
        self.lines = []
        super.init(viewModel: viewModel, nibName: "MainSignUpViewController")
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
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
    
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel) {
        showLoadingMessageAlert()
    }

    func viewModeldidFinishLoginInWithFBOk(viewModel: MainSignUpViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.dismissViewControllerAnimated(true, completion: self?.afterLoginAction)
        }
    }

    func viewModeldidCancelLoginInWithFBOk(viewModel: MainSignUpViewModel) {
        dismissLoadingMessageAlert()
    }

    func viewModel(viewModel: MainSignUpViewModel, didFailLoginInWithFB message: String) {
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
        
        // Navigation bar
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .Plain, target: self,
            action: Selector("closeButtonPressed"))
        navigationItem.leftBarButtonItem = closeButton
        let helpButton = UIBarButtonItem(title: LGLocalizedString.mainSignUpHelpButton, style: .Plain, target: self,
            action: Selector("helpButtonPressed"))
        navigationItem.rightBarButtonItem = helpButton

        // Appearance
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        connectFBButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        signUpButton.layer.cornerRadius = StyleHelper.defaultCornerRadius

        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        logInButton.layer.cornerRadius = StyleHelper.defaultCornerRadius

        // i18n
        claimLabel.text = LGLocalizedString.mainSignUpClaimLabel
        quicklyLabel.text = LGLocalizedString.mainSignUpQuicklyLabel
        
        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        orLabel.text = LGLocalizedString.mainSignUpOrLabel
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, forState: .Normal)
        logInButton.setTitle(LGLocalizedString.mainSignUpLogInLabel, forState: .Normal)

        setupTermsAndConditions()
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textAlignment = .Center
        legalTextView.delegate = self
    }
}
