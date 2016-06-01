//
//  VerifyAccountViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class VerifyAccountViewController: BaseViewController, GIDSignInUIDelegate {

    @IBOutlet weak var contentContainer: UIView!

    @IBOutlet weak var iconImage: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textFieldContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textFieldContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var actionButtonIcon: UIImageView!
    @IBOutlet weak var actionButton: UIButton!

    private let textFieldDefaultHeight: CGFloat = 44
    private let textFieldDefaultBottom: CGFloat = 20
    private let textFieldHiddenBottom: CGFloat = 7

    private let viewModel: VerifyAccountViewModel

    // MARK: - View Lifecycle

    init(viewModel: VerifyAccountViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "VerifyAccountViewController", statusBarStyle: .LightContent)
        viewModel.delegate = self
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

    override func viewWillAppear(animated: Bool) {
        GIDSignIn.sharedInstance().uiDelegate = self
    }


    // MARK: - Private methods

    private func setupUI() {
        contentContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        textFieldContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        setupContentUI()
    }

    private func setupContentUI() {
        textFieldContainerHeight.constant = 0
        textFieldContainerBottom.constant = textFieldHiddenBottom

        switch viewModel.type {
        case .Facebook:
            iconImage.image = UIImage(named: "ic_facebook_big")
            actionButton.setStyle(.Facebook)
            actionButton.setTitle(LGLocalizedString.profileVerifyFacebookButton, forState: .Normal)
            actionButtonIcon.image = UIImage(named: "ic_facebook_rounded")
            titleLabel.textColor = UIColor.facebookColor
            titleLabel.text = LGLocalizedString.profileVerifyFacebookTitle
            messageLabel.text = LGLocalizedString.profileVerifyFacebookMessage
        case .Google:
            iconImage.image = UIImage(named: "ic_google_big")
            actionButton.setStyle(.Google)
            actionButton.setTitle(LGLocalizedString.profileVerifyGoogleButton, forState: .Normal)
            actionButtonIcon.image = UIImage(named: "ic_google_rounded")
            titleLabel.textColor = UIColor.googleColor
            titleLabel.text = LGLocalizedString.profileVerifyGoogleTitle
            messageLabel.text = LGLocalizedString.profileVerifyGoogleMessage
        case let .Email(presentEmail):
            iconImage.image = UIImage(named: "ic_email_big")
            actionButton.setStyle(.Primary(fontSize: .Big))
            actionButton.setTitle(LGLocalizedString.profileVerifyEmailButton, forState: .Normal)
            actionButtonIcon.hidden = true
            titleLabel.text = LGLocalizedString.profileVerifyEmailTitle
            if let presentEmail = presentEmail {
                messageLabel.text = LGLocalizedString.profileVerifyEmailMessagePresent(presentEmail)
            } else {
                messageLabel.text = LGLocalizedString.profileVerifyEmailMessageNotPresent
                emailTextField.placeholder = LGLocalizedString.profileVerifyEmailPlaceholder
                textFieldContainerHeight.constant = textFieldDefaultHeight
                textFieldContainerBottom.constant = textFieldDefaultBottom
            }
        }
    }
}


// MARK: - Actions

extension VerifyAccountViewController {

    @IBAction func closeButtonPressed(sender: AnyObject) {
        viewModel.closeButtonPressed()
    }

    @IBAction func actionButtonPressed(sender: AnyObject) {
        viewModel.actionButtonPressed()
    }
}


// MARK: - VerifyAccountViewModelDelegate

extension VerifyAccountViewController: VerifyAccountViewModelDelegate {

}
