//
//  PopupSignUpViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PopupSignUpViewController: BaseViewController, SignUpViewModelDelegate, UITextViewDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectGoogleButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var legalTextView: UITextView!

    var preDismissAction: (() -> Void)?
    var afterLoginAction: (() -> Void)?

    private var viewModel: SignUpViewModel
    private var topMessage: String


    // MARK: - Lifecycle

    init(viewModel: SignUpViewModel, topMessage: String) {
        self.viewModel = viewModel
        self.topMessage = topMessage
        super.init(viewModel: viewModel, nibName: "PopupSignUpViewController")
        self.viewModel.delegate = self
        modalPresentationStyle = .OverCurrentContext
        modalTransitionStyle = .CrossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        GIDSignIn.sharedInstance().uiDelegate = self
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.abandon()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func connectFBButtonPressed(sender: AnyObject) {
        viewModel.logInWithFacebook()
    }
    @IBAction func connectGoogleButtonPressed(sender: AnyObject) {
        viewModel.logInWithGoogle()
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        presentSignupWithViewModel(viewModel.loginSignupViewModelForSignUp())
    }

    @IBAction func logInButtonPressed(sender: AnyObject) {
        presentSignupWithViewModel(viewModel.loginSignupViewModelForLogin())
    }


    // MARK: - MainSignUpViewModelDelegate

    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel) {
        showLoadingMessageAlert()
    }

    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.preDismissAction?()
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

    private func setupUI() {

        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        
        connectFBButton.setCustomButtonStyle()
        connectGoogleButton.setCustomButtonStyle()
        
        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        signUpButton.layer.cornerRadius = StyleHelper.defaultCornerRadius

        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        logInButton.layer.cornerRadius = StyleHelper.defaultCornerRadius

        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, forState: .Normal)
        logInButton.setTitle(LGLocalizedString.mainSignUpLogInLabel, forState: .Normal)

        claimLabel.text = topMessage

        setupTermsAndConditions()
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textAlignment = .Center
        legalTextView.delegate = self
    }

    private func presentSignupWithViewModel(viewModel: SignUpLogInViewModel) {
        let vc = SignUpLogInViewController(viewModel: viewModel)
        vc.preDismissAction = { [weak self] in
            self?.view.hidden = true
            self?.preDismissAction?()
        }
        vc.afterLoginAction = { [weak self] in
            self?.dismissViewControllerAnimated(false, completion: self?.afterLoginAction)
        }
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }
}
