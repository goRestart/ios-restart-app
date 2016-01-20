//
//  PopupSignUpViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PopupSignUpViewController: BaseViewController, MainSignUpViewModelDelegate, UITextViewDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var legalTextView: UITextView!

    var afterLoginAction: (() -> Void)?

    private var viewModel: MainSignUpViewModel
    private var topMessage: String

    // MARK: - Lifecycle

    init(viewModel: MainSignUpViewModel, topMessage: String) {
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
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.abandon()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func connectFBButtonPressed(sender: AnyObject) {
        viewModel.logInWithFacebook()
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let vc = SignUpLogInViewController(viewModel: viewModel.loginSignupViewModelForSignUp())
        vc.afterLoginAction = afterLoginAction
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
    }

    @IBAction func logInButtonPressed(sender: AnyObject) {
        let vc = SignUpLogInViewController(viewModel: viewModel.loginSignupViewModelForLogin())
        vc.afterLoginAction = afterLoginAction
        let navC = UINavigationController(rootViewController: vc)
        presentViewController(navC, animated: true, completion: nil)
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

    private func setupUI() {

        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        connectFBButton.setBackgroundImage(connectFBButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        connectFBButton.layer.cornerRadius = StyleHelper.defaultCornerRadius
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
}
