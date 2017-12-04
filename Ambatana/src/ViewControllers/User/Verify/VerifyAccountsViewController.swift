//
//  VerifyAccountsViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 30/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VerifyAccountsViewController: BaseViewController, GIDSignInUIDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var contentContainerCenterY: NSLayoutConstraint!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var fbContainer: UIView!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var googleContainer: UIView!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var emailButtonLogo: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextFieldLogo: UIImageView!
    @IBOutlet weak var emailTextFieldButton: UIButton!

    @IBOutlet weak var fbContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var fbContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var googleContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var googleContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var emailContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var emailContainerBottom: NSLayoutConstraint!

    private let disposeBag = DisposeBag()

    private let emailContainerInvisibleMargin: CGFloat = 10

    private let viewModel: VerifyAccountsViewModel
    private let keyboardHelper: KeyboardHelper


    // MARK: - View Lifecycle

    convenience init(viewModel: VerifyAccountsViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper())
    }

    init(viewModel: VerifyAccountsViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.keyboardHelper = keyboardHelper
        super.init(viewModel: viewModel, nibName: "VerifyAccountsViewController", statusBarStyle: .lightContent)
        viewModel.delegate = self
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()
        setupRx()
    }


    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = UIColor.blackBackgroundAlpha
        contentContainer.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        fbButton.setStyle(.facebook)
        googleButton.setStyle(.google)
        emailButton.rounded = true
        emailContainer.rounded = true
        emailTextFieldButton.rounded = true
        emailTextField.placeholder = LGLocalizedString.profileVerifyEmailButton

        titleLabel.text = viewModel.titleText
        descriptionLabel.text = viewModel.descriptionText

        fbButton.setTitle(LGLocalizedString.profileVerifyFacebookButton, for: .normal)
        googleButton.setTitle(LGLocalizedString.profileVerifyGoogleButton, for: .normal)
        emailButton.setTitle(LGLocalizedString.profileVerifyEmailButton, for: .normal)

        if viewModel.fbButtonState.value == .hidden {
            fbContainerHeight.constant = 0
            fbContainerBottom.constant = 0
            fbButton.isHidden = true
        }
        if viewModel.googleButtonState.value == .hidden {
            googleContainerHeight.constant = 0
            googleContainerBottom.constant = 0
            googleButton.isHidden = true
        }
        if viewModel.emailButtonState.value == .hidden {
            emailContainerHeight.constant = 0
            emailContainerBottom.constant = emailContainerInvisibleMargin
            emailContainer.isHidden = true
        }
    }

    private func setupRx() {
        viewModel.fbButtonState.asObservable().bind(to: fbButton.rx.verifyState).disposed(by: disposeBag)
        viewModel.googleButtonState.asObservable().bind(to: googleButton.rx.verifyState).disposed(by: disposeBag)
        viewModel.emailButtonState.asObservable().bind(to: emailButton.rx.verifyState).disposed(by: disposeBag)
        viewModel.typedEmailState.asObservable().bind(to: emailTextFieldButton.rx.verifyState).disposed(by: disposeBag)
        viewModel.typedEmailState.asObservable().map { state in
            switch state {
            case .hidden:
                return true
            case .loading, .enabled, .disabled:
                return false
            }
        }.bind { [weak self] (hidden:Bool) in
            self?.emailButtonLogo.isHidden = !hidden
            self?.emailTextField.isHidden = hidden
            self?.emailTextFieldLogo.isHidden = hidden
        }.disposed(by: disposeBag)

        backgroundButton.rx.tap.bind { [weak self] in self?.viewModel.closeButtonPressed() }.disposed(by: disposeBag)
        fbButton.rx.tap.bind { [weak self] in self?.viewModel.fbButtonPressed()}.disposed(by: disposeBag)
        googleButton.rx.tap.bind { [weak self] in self?.googleButtonPressed() }.disposed(by: disposeBag)
        emailButton.rx.tap.bind { [weak self] in self?.viewModel.emailButtonPressed() }.disposed(by: disposeBag)
        emailTextFieldButton.rx.tap.bind { [weak self] in self?.viewModel.typedEmailButtonPressed() }.disposed(by: disposeBag)
        emailTextField.rx.text.map { ($0 ?? "") }.bind(to: viewModel.typedEmail).disposed(by: disposeBag)
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bind { [weak self] origin in
            guard let viewHeight = self?.view.height, let animationTime = self?.keyboardHelper.animationTime, viewHeight >= origin else { return }
            self?.contentContainerCenterY.constant = -((viewHeight - origin)/2)
            UIView.animate(withDuration: Double(animationTime), animations: {[weak self] in self?.view.layoutIfNeeded()})
        }.disposed(by: disposeBag)
    }

    // MARK: - Google login.
    
    private func googleButtonPressed() {
        GIDSignIn.sharedInstance().uiDelegate = self
        viewModel.googleButtonPressed()
    }
}


// MARK: - VerifyAccountsViewModelDelegate

extension VerifyAccountsViewController: VerifyAccountsViewModelDelegate {
    func vmResignResponders() {
        emailTextField.resignFirstResponder()
    }
}


// MARK: - Accesibility

extension VerifyAccountsViewController {
    func setAccesibilityIds() {
        backgroundButton.accessibilityId = .verifyAccountsBackgroundButton
        fbButton.accessibilityId = .verifyAccountsFacebookButton
        googleButton.accessibilityId = .verifyAccountsGoogleButton
        emailButton.accessibilityId = .verifyAccountsEmailButton
        emailTextField.accessibilityId = .verifyAccountsEmailTextField
        emailTextFieldButton.accessibilityId = .verifyAccountsEmailTextFieldButton
    }
}
