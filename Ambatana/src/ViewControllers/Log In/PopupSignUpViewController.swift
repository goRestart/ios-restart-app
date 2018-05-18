//
//  PopupSignUpViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import GoogleSignIn
import UIKit

final class PopupSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate, SignUpViewModelDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var connectFBButton: LetgoButton!
    @IBOutlet weak var connectGoogleButton: LetgoButton!
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }


    // MARK: - Actions

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeButtonPressed()
    }

    @IBAction func connectFBButtonPressed(_ sender: AnyObject) {
        viewModel.connectFBButtonPressed()
    }
    @IBAction func connectGoogleButtonPressed(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().uiDelegate = self
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
        viewModel.urlPressed(url: url)
        return false
    }


    // MARK: - Private methods

    private func setupUI() {

        contentContainer.cornerRadius = LGUIKitConstants.smallCornerRadius
        
        connectFBButton.setStyle(.facebook)
        connectGoogleButton.setStyle(.google)

        signUpButton.setBackgroundImage(signUpButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            for: .normal)
        signUpButton.cornerRadius = LGUIKitConstants.smallCornerRadius

        logInButton.setBackgroundImage(logInButton.backgroundColor?.imageWithSize(CGSize(width: 1, height: 1)),
            for: .normal)
        logInButton.cornerRadius = LGUIKitConstants.smallCornerRadius

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
