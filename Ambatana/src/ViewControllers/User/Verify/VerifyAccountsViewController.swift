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
    @IBOutlet weak var closeButton: UIButton!
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
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance)
    }

    init(viewModel: VerifyAccountsViewModel, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.keyboardHelper = keyboardHelper
        super.init(viewModel: viewModel, nibName: "VerifyAccountsViewController", statusBarStyle: .LightContent)
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
        setAccesibilityIds()
        setupRx()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func vmDismiss(completion: (() -> Void)?) {
        emailTextField.resignFirstResponder()
        super.vmDismiss(completion)
    }


    // MARK: - Private

    private func setupUI() {
        contentContainer.layer.cornerRadius = LGUIKitConstants.alertCornerRadius
        fbButton.setStyle(.Facebook)
        googleButton.setStyle(.Google)
        emailButton.layer.cornerRadius = emailButton.height/2
        emailContainer.layer.cornerRadius = emailContainer.height/2
        emailTextFieldButton.layer.cornerRadius = emailTextFieldButton.height/2
        emailTextField.placeholder = LGLocalizedString.profileVerifyEmailButton

        titleLabel.text = LGLocalizedString.chatConnectAccountsTitle
        descriptionLabel.text = viewModel.descriptionText

        fbButton.setTitle(LGLocalizedString.profileVerifyFacebookButton, forState: .Normal)
        googleButton.setTitle(LGLocalizedString.profileVerifyGoogleButton, forState: .Normal)
        emailButton.setTitle(LGLocalizedString.profileVerifyEmailButton, forState: .Normal)

        if viewModel.fbButtonState.value == .Hidden {
            fbContainerHeight.constant = 0
            fbContainerBottom.constant = 0
        }
        if viewModel.googleButtonState.value == .Hidden {
            googleContainerHeight.constant = 0
            googleContainerBottom.constant = 0
        }
        if viewModel.emailButtonState.value == .Hidden {
            emailContainerHeight.constant = 0
            emailContainerBottom.constant = emailContainerInvisibleMargin
        } else {
            emailButton.hidden = viewModel.emailRequiresInput
            emailButtonLogo.hidden = viewModel.emailRequiresInput
            emailTextField.hidden = !viewModel.emailRequiresInput
            emailTextFieldLogo.hidden = !viewModel.emailRequiresInput
            emailTextFieldButton.hidden = !viewModel.emailRequiresInput
        }
    }

    private func setupRx() {
        viewModel.fbButtonState.asObservable().bindTo(fbButton.rx_veryfy_state).addDisposableTo(disposeBag)
        viewModel.googleButtonState.asObservable().bindTo(googleButton.rx_veryfy_state).addDisposableTo(disposeBag)
        if viewModel.emailRequiresInput {
            viewModel.emailButtonState.asObservable().bindTo(emailTextFieldButton.rx_veryfy_state).addDisposableTo(disposeBag)
        } else {
            viewModel.emailButtonState.asObservable().bindTo(emailButton.rx_veryfy_state).addDisposableTo(disposeBag)
        }

        backgroundButton.rx_tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)
        closeButton.rx_tap.bindNext { [weak self] in self?.viewModel.closeButtonPressed() }.addDisposableTo(disposeBag)
        fbButton.rx_tap.bindNext { [weak self] in self?.viewModel.fbButtonPressed()}.addDisposableTo(disposeBag)
        googleButton.rx_tap.bindNext { [weak self] in self?.viewModel.googleButtonPressed() }.addDisposableTo(disposeBag)
        emailButton.rx_tap.bindNext { [weak self] in self?.viewModel.emailButtonPressed() }.addDisposableTo(disposeBag)
        emailTextFieldButton.rx_tap.bindNext { [weak self] in self?.viewModel.emailButtonPressed() }.addDisposableTo(disposeBag)
        emailTextField.rx_text.bindTo(viewModel.typedEmail).addDisposableTo(disposeBag)

        setupKeyboardRx()
    }

    private func setupKeyboardRx() {
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bindNext { [weak self] origin in
            guard let viewHeight = self?.view.height, animationTime = self?.keyboardHelper.animationTime
                where viewHeight >= origin else { return }
            self?.contentContainerCenterY.constant = -((viewHeight - origin)/2)
            UIView.animateWithDuration(Double(animationTime), animations: {[weak self] in self?.view.layoutIfNeeded()})
            }.addDisposableTo(disposeBag)
    }
}


// MARK: - VerifyAccountsViewModelDelegate

extension VerifyAccountsViewController: VerifyAccountsViewModelDelegate {}


// MARK: - Accesibility

extension VerifyAccountsViewController {
    func setAccesibilityIds() {
        backgroundButton.accessibilityId = .VerifyAccountsBackgroundButton
        closeButton.accessibilityId = .VerifyAccountsCloseButton
        fbButton.accessibilityId = .VerifyAccountsFacebookButton
        googleButton.accessibilityId = .VerifyAccountsGoogleButton
        emailButton.accessibilityId = .VerifyAccountsEmailButton
        emailTextField.accessibilityId = .VerifyAccountsEmailTextField
        emailTextFieldButton.accessibilityId = .VerifyAccountsEmailTextFieldButton
    }
}


// MARK: - UIButton + VerifyButtonState

extension UIButton {
    var rx_veryfy_state: AnyObserver<VerifyButtonState> {
        return UIBindingObserver(UIElement: self) { button, state in
            switch state {
            case .Hidden:
                button.hidden = true
            case .Enabled:
                button.hidden = false
                button.enabled = true
            case .Disabled, .Loading:
                button.hidden = false
                button.enabled = false
            }
        }.asObserver()
    }
}
