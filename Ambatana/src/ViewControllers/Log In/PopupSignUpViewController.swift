//
//  PopupSignUpViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PopupSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate {

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
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }

    @IBAction func connectFBButtonPressed(sender: AnyObject) {
        viewModel.connectFBButtonPressed()
    }
    @IBAction func connectGoogleButtonPressed(sender: AnyObject) {
        viewModel.connectGoogleButtonPressed()
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        viewModel.signUpButtonPressed()
    }

    @IBAction func logInButtonPressed(sender: AnyObject) {
        viewModel.logInButtonPressed()
    }


    // MARK: UITextViewDelegate

    func textView(textView: UITextView, shouldInteractWithURL url: NSURL, inRange characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }


    // MARK: - Private methods

    private func setupUI() {

        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        connectFBButton.setStyle(.Facebook)
        connectGoogleButton.setStyle(.Google)

        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        signUpButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            forState: .Normal)
        logInButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, forState: .Normal)
        connectGoogleButton.setTitle(LGLocalizedString.mainSignUpGoogleConnectButton, forState: .Normal)
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


// MARK: - SignUpViewModelDelegate

extension PopupSignUpViewController: SignUpViewModelDelegate {

    func vmOpenSignup(viewModel: SignUpLogInViewModel) {
        presentSignupWithViewModel(viewModel)
    }

    func vmFinish(completedLogin completed: Bool) {
        preDismissAction?()
        dismissViewControllerAnimated(true, completion: completed ? afterLoginAction : nil)
    }

    func vmFinishAndShowScammerAlert(contactUrl: NSURL) {
        let parentController = presentingViewController
        let contact = UIAction(
            interface: .Button(LGLocalizedString.loginScammerAlertContactButton, .Primary(fontSize: .Medium)),
            action: {
                parentController?.openInternalUrl(contactUrl)
        })
        let keepBrowsing = UIAction(
            interface: .Button(LGLocalizedString.loginScammerAlertKeepBrowsingButton, .Secondary(fontSize: .Medium, withBorder: false)),
            action: {})
        dismissViewControllerAnimated(false) {
            parentController?.showAlertWithTitle(LGLocalizedString.loginScammerAlertTitle,
                                                 text: LGLocalizedString.loginScammerAlertMessage,
                                                 alertType: .IconAlert(icon: UIImage(named: "ic_moderation_alert")),
                                                 buttonsLayout: .Vertical, actions:  [contact, keepBrowsing])
        }
    }
}
