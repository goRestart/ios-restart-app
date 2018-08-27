import GoogleSignIn
import UIKit
import LGComponents

final class PopupSignUpViewController: BaseViewController, UITextViewDelegate, GIDSignInUIDelegate, SignUpViewModelDelegate {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var connectFBButton: LetgoButton!
    @IBOutlet weak var connectGoogleButton: LetgoButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var legalTextView: UITextView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var googleLogo: UIImageView!
    @IBOutlet weak var logoFacebook: UIImageView!
    
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
        setupRAssets()
    }

    private func setupRAssets() {
        logoFacebook.image = R.Asset.IconsButtons.icFacebookRounded.image
        googleLogo.image = R.Asset.IconsButtons.icGoogleRounded.image
        closeButton.setImage(R.Asset.IconsButtons.icCloseDark.image, for: .normal)
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

        connectFBButton.setTitle(R.Strings.mainSignUpFacebookConnectButton, for: .normal)
        connectGoogleButton.setTitle(R.Strings.mainSignUpGoogleConnectButton, for: .normal)
        signUpButton.setTitle(R.Strings.mainSignUpSignUpButton, for: .normal)
        logInButton.setTitle(R.Strings.mainSignUpLogInLabel, for: .normal)

        claimLabel.text = topMessage

        setupTermsAndConditions()
    }

    private func setupTermsAndConditions() {
        legalTextView.attributedText = viewModel.attributedLegalText
        legalTextView.textAlignment = .center
        legalTextView.delegate = self
    }
}
