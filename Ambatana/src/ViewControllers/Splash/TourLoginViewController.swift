import GoogleSignIn
import LGCoreKit
import RxSwift
import LGComponents

final class TourLoginViewController: BaseViewController, GIDSignInUIDelegate {
    @IBOutlet weak var kenBurnsView: KenBurnsView!

    @IBOutlet weak var topLogoImage: UIImageView!
    @IBOutlet weak var claimLabel: UILabel!
    @IBOutlet weak var claimLabelTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var facebookButton: LetgoButton!
    @IBOutlet weak var facebookIcon: UIImageView!
    @IBOutlet weak var googleButton: LetgoButton!
    @IBOutlet weak var googleIcon: UIImageView!
    @IBOutlet var orDividerViews: [UIView]!
    @IBOutlet weak var orUseEmailLabel: UILabel!
    @IBOutlet weak var orUseEmailLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailButtonJustText: UIButton!
    @IBOutlet weak var emailButtonTopContraint: NSLayoutConstraint!
    @IBOutlet weak var mainViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var footerTextView: UITextView!
    @IBOutlet weak var footerTextViewBottomConstraint: NSLayoutConstraint!

    fileprivate var lines: [CALayer] = []

    fileprivate let viewModel: TourLoginViewModel
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    init(viewModel: TourLoginViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "TourLoginViewController", statusBarStyle: .lightContent,
                   navBarBackgroundStyle: .transparent(substyle: .dark))

        self.viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()

        if DeviceFamily.current == .iPhone4 {
            adaptConstraintsToiPhone4()
        }
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        setupKenBurns()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLines()
    }


    // MARK: - IBActions
    
    @IBAction func facebookButtonPressed(_ sender: AnyObject) {
        viewModel.facebookButtonPressed()
    }

    @IBAction func googleButtonPressed(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().uiDelegate = self
        viewModel.googleButtonPressed()
    }

    @IBAction func emailButtonPressed(_ sender: AnyObject) {
        viewModel.emailButtonPressed()
    }
}


// MARK: - UITextViewDelegate

extension TourLoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange) -> Bool {
        viewModel.textUrlPressed(url: url)
        return false
    }
}


// MARK: TourLoginViewModelDelegate 

extension TourLoginViewController: TourLoginViewModelDelegate {}


// MARK: - Private UI methods

fileprivate extension TourLoginViewController {

    func setupKenBurns() {
        view.layoutIfNeeded()
        kenBurnsView.startAnimation(with: [
            R.Asset.BackgroundsAndImages.bg1New.image,
            R.Asset.BackgroundsAndImages.bg2New.image,
            R.Asset.BackgroundsAndImages.bg3New.image,
            R.Asset.BackgroundsAndImages.bg4New.image
            ])
    }

    func setupUI() {
        view.backgroundColor = .clear
        topLogoImage.image = R.Asset.BackgroundsAndImages.logoOnboarding.image
        if AdminViewController.canOpenAdminPanel() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(openAdminPanel))
            topLogoImage.addGestureRecognizer(tap)
        }

        // UI
        kenBurnsView.clipsToBounds = true
        
        facebookButton.setStyle(.facebook)
        facebookIcon.image = R.Asset.IconsButtons.icFacebookRounded.image
        googleButton.setStyle(.google)
        googleIcon.image = R.Asset.IconsButtons.icGoogleRounded.image
        orUseEmailLabel.text = R.Strings.tourOrLabel
        orUseEmailLabel.font = UIFont.smallBodyFont
        
        emailButtonJustText.isHidden = false

        footerTextView.textAlignment = .center
        footerTextView.delegate = self

        // i18n
        claimLabel.text = R.Strings.tourClaimLabel
        facebookButton.setTitle(R.Strings.tourFacebookButton, for: .normal)
        googleButton.setTitle(R.Strings.tourGoogleButton, for: .normal)
        emailButtonJustText.setTitle(R.Strings.tourContinueWEmail, for: .normal)
        footerTextView.attributedText = viewModel.attributedLegalText
    }

    func adaptConstraintsToiPhone4() {
        claimLabelTopConstraint.constant = 10
        orUseEmailLabelTopConstraint.constant = 10
        emailButtonTopContraint.constant = 10
        mainViewBottomConstraint.constant = 8
        footerTextViewBottomConstraint.constant = 8
    }

    func setupAccessibilityIds() {
        facebookButton.set(accessibilityId: .tourFacebookButton)
        googleButton.set(accessibilityId: .tourGoogleButton)
        emailButtonJustText.set(accessibilityId: .tourEmailButton)
    }

    func setupLines() {
        // Redraw the lines
        lines.forEach { $0.removeFromSuperlayer() }
        lines = []
        orDividerViews.forEach { lines.append($0.addBottomBorderWithWidth(1, color: UIColor.white)) }
    }

    @objc func openAdminPanel() {
        guard AdminViewController.canOpenAdminPanel() else { return }
        let admin = AdminViewController()
        let nav = UINavigationController(rootViewController: admin)
        present(nav, animated: true, completion: nil)
    }
}
