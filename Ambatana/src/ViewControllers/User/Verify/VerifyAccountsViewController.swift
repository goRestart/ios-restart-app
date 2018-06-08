import GoogleSignIn
import UIKit
import RxSwift
import RxCocoa
import LGComponents

final class VerifyAccountsViewController: BaseViewController, GIDSignInUIDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var contentContainerCenterY: NSLayoutConstraint!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var facebookLogo: UIImageView!
    @IBOutlet weak var fbContainer: UIView!
    @IBOutlet weak var fbButton: LetgoButton!
    @IBOutlet weak var googleLogo: UIImageView!
    @IBOutlet weak var googleContainer: UIView!
    @IBOutlet weak var googleButton: LetgoButton!
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        emailButton.setRoundedCorners()
        emailContainer.setRoundedCorners()
        emailTextFieldButton.setRoundedCorners()
    }


    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = UIColor.blackBackgroundAlpha
        contentContainer.cornerRadius = LGUIKitConstants.bigCornerRadius
        fbButton.setStyle(.facebook)
        googleButton.setStyle(.google)
        emailTextField.placeholder = R.Strings.profileVerifyEmailButton

        titleLabel.text = viewModel.titleText
        descriptionLabel.text = viewModel.descriptionText

        fbButton.setTitle(R.Strings.profileVerifyFacebookButton, for: .normal)
        googleButton.setTitle(R.Strings.profileVerifyGoogleButton, for: .normal)
        emailButton.setTitle(R.Strings.profileVerifyEmailButton, for: .normal)

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
        setupRAssets()
    }

    private func setupRAssets() {
        emailButtonLogo.image = R.Asset.IconsButtons.icEmailActive.image
        facebookLogo.image = R.Asset.IconsButtons.icFacebookRounded.image
        googleLogo.image = R.Asset.IconsButtons.icGoogleRounded.image
    }

    private func setupRx() {
        viewModel.fbButtonState.asObservable().bind { [weak self] state in
            self?.fbButton.setState(state)
            }.disposed(by: disposeBag)
        viewModel.googleButtonState.asObservable().bind { [weak self] state in
            self?.googleButton.setState(state)
            }.disposed(by: disposeBag)
        viewModel.emailButtonState.asObservable().bind { [weak self] state in
            self?.emailButton.setState(state)
            }.disposed(by: disposeBag)
        viewModel.typedEmailState.asObservable().bind { [weak self] state in
            self?.emailTextFieldButton.setState(state)
            }.disposed(by: disposeBag)
        
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
        backgroundButton.set(accessibilityId: .verifyAccountsBackgroundButton)
        fbButton.set(accessibilityId: .verifyAccountsFacebookButton)
        googleButton.set(accessibilityId: .verifyAccountsGoogleButton)
        emailButton.set(accessibilityId: .verifyAccountsEmailButton)
        emailTextField.set(accessibilityId: .verifyAccountsEmailTextField)
        emailTextFieldButton.set(accessibilityId: .verifyAccountsEmailTextFieldButton)
    }
}
