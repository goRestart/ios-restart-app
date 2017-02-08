//
//  PopupSignUpViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class PopupSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate, SignUpViewModelDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var connectFBButton: UIButton!
    @IBOutlet weak var connectGoogleButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var legalTextView: UITextView!

    private var viewModel: SignUpViewModel
    private var topMessage: String


    // MARK: - Lifecycle

    init(viewModel: SignUpViewModel, topMessage: String) {
        self.viewModel = viewModel
        self.topMessage = topMessage
        super.init(viewModel: viewModel, nibName: "PopupSignUpViewController")
        self.viewModel.delegate = self
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeButtonPressed()
    }

    @IBAction func connectFBButtonPressed(_ sender: AnyObject) {
        viewModel.connectFBButtonPressed()
    }
    @IBAction func connectGoogleButtonPressed(_ sender: AnyObject) {
        viewModel.connectGoogleButtonPressed()
    }

    @IBAction func signUpButtonPressed(_ sender: AnyObject) {
        viewModel.signUpButtonPressed()
    }

    @IBAction func logInButtonPressed(_ sender: AnyObject) {
        viewModel.logInButtonPressed()
    }


    // MARK: UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        openInternalUrl(url)
        return false
    }


    // MARK: - Private methods

    private func setupUI() {

        contentContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        
        connectFBButton.setStyle(.facebook)
        connectGoogleButton.setStyle(.google)

        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            for: .normal)
        signUpButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            for: .normal)
        logInButton.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        connectFBButton.setTitle(LGLocalizedString.mainSignUpFacebookConnectButton, for: .normal)
        connectGoogleButton.setTitle(LGLocalizedString.mainSignUpGoogleConnectButton, for: .normal)
        signUpButton.setTitle(LGLocalizedString.mainSignUpSignUpButton, for: .normal)
        logInButton.setTitle(LGLocalizedString.mainSignUpLogInLabel, for: .normal)

        claimLabel.text = topMessage

        setupTermsAndConditions()
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textAlignment = .center
        legalTextView.delegate = self
    }
}
