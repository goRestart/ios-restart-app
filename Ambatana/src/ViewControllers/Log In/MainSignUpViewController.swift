import GoogleSignIn
import LGCoreKit
import Result
import RxSwift
import LGComponents

class MainSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate, SignUpViewModelDelegate {
    
    // > ViewModel
    var viewModel: SignUpViewModel
    
    // UI
    @IBOutlet weak var logoBigImageView: UIImageView!
    // > Header
    @IBOutlet weak var claimLabel: UILabel!
    
    // > Main View
    
    @IBOutlet weak var firstDividerView: UIView!
    @IBOutlet weak var quicklyLabel: UILabel!

    @IBOutlet weak var connectFBButton: LetgoButton!
    @IBOutlet weak var logoFacebook: UIImageView!
    @IBOutlet weak var connectGoogleButton: LetgoButton!
    @IBOutlet weak var logoGoogle: UIImageView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var orLabel: UILabel!

    @IBOutlet weak var signUpButton: LetgoButton!
    @IBOutlet weak var logInButton: LetgoButton!
    
    // Footer
    
    @IBOutlet weak var legalTextView: UITextView!
    
    // Constraints to adapt for iPhone 4/5
    @IBOutlet weak var mainViewHeightProportion: NSLayoutConstraint!
    @IBOutlet weak var loginButtonBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var orDividerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var googleButtonTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var facebookButtonTopMarginConstraint: NSLayoutConstraint!
    
    // Bar Buttons
    fileprivate var closeButton: UIBarButtonItem?
    fileprivate var helpButton: UIBarButtonItem?

    // > Helper
    var lines: [CALayer]

    private let disposeBag: DisposeBag

    
    // MARK: - Lifecycle
    
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        self.lines = []
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "MainSignUpViewController",
                   navBarBackgroundStyle: .transparent(substyle: .light))
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
        setAccesibilityIds()

        switch DeviceFamily.current {
        case .iPhone4:
            adaptConstraintsToiPhone4()
        case .iPhone5:
            adaptConstraintsToiPhone5()
        default:
            break
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(dividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
        lines.append(firstDividerView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }

    
    // MARK: - Actions
    
    @objc func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    @objc func helpButtonPressed() {
        viewModel.helpButtonPressed()
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
    // MARK: > UI
    
    private func setupUI() {

        // View
        view.backgroundColor = UIColor.white

        // Navigation bar
        closeButton = UIBarButtonItem(image: R.Asset.IconsButtons.navbarClose.image, style: .plain, target: self,
            action: #selector(MainSignUpViewController.closeButtonPressed))
        navigationItem.leftBarButtonItem = closeButton
        helpButton = UIBarButtonItem(title: R.Strings.mainSignUpHelpButton, style: .plain, target: self,
            action: #selector(MainSignUpViewController.helpButtonPressed))
        navigationItem.rightBarButtonItem = helpButton

        // Appearance
        connectFBButton.setStyle(.facebook)
        connectGoogleButton.setStyle(.google)

        signUpButton.setStyle(.secondary(fontSize: .medium, withBorder: true))
        logInButton.setStyle(.secondary(fontSize: .medium, withBorder: true))

        // i18n
        claimLabel.text = R.Strings.mainSignUpClaimLabel
        claimLabel.font = UIFont.smallBodyFont
        claimLabel.textColor = UIColor.lgBlack
        quicklyLabel.text = R.Strings.mainSignUpQuicklyLabel
        quicklyLabel.font = UIFont.smallBodyFont
        quicklyLabel.backgroundColor = view.backgroundColor

        orLabel.text = R.Strings.mainSignUpOrLabel
        orLabel.font = UIFont.smallBodyFont
        orLabel.backgroundColor = view.backgroundColor
        signUpButton.setTitle(R.Strings.mainSignUpSignUpButton, for: .normal)
        logInButton.setTitle(R.Strings.mainSignUpLogInLabel, for: .normal)

        setupTermsAndConditions()
        setupRAssets()
    }

    private func setupRAssets() {
        logoBigImageView.image = R.Asset.BackgroundsAndImages.logoBig.image
        logoFacebook.image = R.Asset.IconsButtons.icFacebookRounded.image
        logoGoogle.image = R.Asset.IconsButtons.icGoogleRounded.image
    }

    private func setupRx() {
        // Facebook button title
        viewModel.previousFacebookUsername.asObservable()
            .map { username in
                if let username = username {
                    return R.Strings.mainSignUpFacebookConnectButtonWName(username)
                } else {
                    return R.Strings.mainSignUpFacebookConnectButton
                }
            }.bind(to: connectFBButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        // Google button title
        viewModel.previousGoogleUsername.asObservable()
            .map { username in
                if let username = username {
                    return R.Strings.mainSignUpGoogleConnectButtonWName(username)
                } else {
                    return R.Strings.mainSignUpGoogleConnectButton
                }
            }.bind(to: connectGoogleButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }
    
    private func adaptConstraintsToiPhone4() {
        mainViewHeightProportion.constant = 100
        loginButtonBottomMarginConstraint.constant = 0
        signUpButtonTopMarginConstraint.constant = 10
        orDividerTopMarginConstraint.constant = 15
        googleButtonTopMarginConstraint.constant = 8
        facebookButtonTopMarginConstraint.constant = 8
    }

    private func adaptConstraintsToiPhone5() {
        mainViewHeightProportion.constant = 70
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textContainer.maximumNumberOfLines = 3
        legalTextView.textAlignment = .center
        legalTextView.delegate = self
    }
}


// MARK: - Accesibility

extension MainSignUpViewController {
    func setAccesibilityIds() {
        connectFBButton.set(accessibilityId: .mainSignUpFacebookButton)
        connectGoogleButton.set(accessibilityId: .mainSignUpGoogleButton)
        signUpButton.set(accessibilityId: .mainSignUpSignupButton)
        logInButton.set(accessibilityId: .mainSignupLogInButton)
        closeButton?.set(accessibilityId: .mainSignupCloseButton)
        helpButton?.set(accessibilityId: .mainSignupHelpButton)
    }
}
