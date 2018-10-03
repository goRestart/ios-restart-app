import UIKit
import LGComponents

final class ListingPostedViewController: BaseViewController, ListingPostedViewModelDelegate {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var loadingIndicator: LoadingIndicator!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!

    // Edit Container
    @IBOutlet weak var editContainer: UIView!
    @IBOutlet weak var editContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var editOrLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mainButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var mainButton: LetgoButton!

    // incentivize items
    @IBOutlet weak var incentiveContainer: UIView!

    private static let contentContainerShownHeight: CGFloat = 80
    fileprivate let viewModel: ListingPostedViewModel
    private let socialSharer: SocialSharer

    // MARK: - View lifecycle

    convenience init(viewModel: ListingPostedViewModel) {
        self.init(viewModel: viewModel, socialSharer: SocialSharer())
    }

    required init(viewModel: ListingPostedViewModel, socialSharer: SocialSharer) {
        self.viewModel = viewModel
        self.socialSharer = socialSharer
        super.init(viewModel: viewModel, nibName: "ListingPostedViewController")
        viewModel.delegate = self
        socialSharer.delegate = self
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        setReachabilityEnabled(false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setAccesibilityIds()
    }

    override func viewDidFirstAppear(_ animated: Bool) {
        super.viewDidFirstAppear(animated)
        guard viewModel.shouldAutoShareOnFacebook else { return }
        shareOnFacebook()
    }

    // MARK: - Status Bar
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - IBActions

    @IBAction func onCloseButton(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func onMainButton(_ sender: AnyObject) {
        viewModel.mainActionPressed()
    }

    @IBAction func onSharebutton(_ sender: AnyObject) {
        viewModel.shareActionPressed()
    }
    
    @IBAction func onEditButton(_ sender: AnyObject) {
        viewModel.editActionPressed()
    }


    // MARK: - ListingPostedViewModelDelegate

    func productPostedViewModelSetupLoadingState(_ viewModel: ListingPostedViewModel) {
        setupLoading()
    }

    func productPostedViewModel(_ viewModel: ListingPostedViewModel, finishedLoadingState correct: Bool) {
        finishedLoading(correct)
    }

    func productPostedViewModel(_ viewModel: ListingPostedViewModel, setupStaticState correct: Bool) {
        setupStatic(correct)
    }
    
    func listingPostedViewModelShareNative() {
        shareButtonPressed()
    }

    // MARK: - Private methods

    private func setupView() {
        closeButton.setImage(R.Asset.CongratsScreenImages.icCloseRed.image, for: .normal)
        shareButton.setImage(R.Asset.CongratsScreenImages.icShareRed.image, for: .normal)
        mainButton.setStyle(.primary(fontSize: .big))
        mainButton.isHidden = viewModel.mainButtonHidden
        editOrLabel.text = R.Strings.productPostConfirmationAnother.localizedUppercase
        editButton.setTitle(R.Strings.productPostConfirmationEdit, for: .normal)
        loadingIndicator.color = UIColor.primaryColor

        let postIncentivatorView = PostIncentivatorView.postIncentivatorView(viewModel.wasFreePosting,
                                                                             isServicesListing: false)
        incentiveContainer.addSubview(postIncentivatorView)
        let views: [String : Any] = ["postIncentivatorView": postIncentivatorView]
        incentiveContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        incentiveContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[postIncentivatorView]|",
            options: [], metrics: nil, views: views))
        postIncentivatorView.delegate = self
        postIncentivatorView.setupIncentiviseView()
    }

    private func setupStatic(_ loadingSuccessful: Bool) {
        loadingIndicator.isHidden = true
        mainTextLabel.text = viewModel.mainText
        secondaryTextLabel.text = viewModel.secondaryText
        mainButton.setTitle(viewModel.mainButtonText, for: .normal)

        if !loadingSuccessful {
            editContainer.isHidden = true
            editContainerHeight.constant = 0
            shareButton.isHidden = true
            incentiveContainer.isHidden = true
        }
    }

    private func setupLoading() {
        mainTextLabel.alpha = 0
        mainTextLabel.text = nil
        secondaryTextLabel.alpha = 0
        secondaryTextLabel.text = nil
        editContainer.alpha = 0
        shareButton.alpha = 0
        mainButton.alpha = 0
        editContainerHeight.constant = 0
        mainButtonHeight.constant = 0
        loadingIndicator.startAnimating()
        incentiveContainer.isHidden = true
    }

    private func finishedLoading(_ correct: Bool) {
        mainButton.setTitle(viewModel.mainButtonText, for: .normal)
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimating(correctState: correct) { [weak self] in
            if correct {
                self?.editContainerHeight.constant = ListingPostedViewController.contentContainerShownHeight
                self?.incentiveContainer.isHidden = false
            }
            self?.mainButtonHeight.constant = LGUIKitConstants.enabledButtonHeight
            UIView.animate(withDuration: 0.2,
                animations: { [weak self] in
                    self?.mainTextLabel.text = self?.viewModel.mainText
                    self?.secondaryTextLabel.text = self?.viewModel.secondaryText
                    self?.mainTextLabel.alpha = 1
                    self?.secondaryTextLabel.alpha = 1
                    if correct {
                        self?.editContainer.alpha = 1
                        self?.shareButton.alpha = 1
                    }
                    self?.mainButton.alpha = 1
                    self?.view.layoutIfNeeded()
                },
                completion: { finished in
                }
            )
        }
    }

    private func shareButtonPressed() {
        guard let socialMessage = viewModel.socialMessage else { return }
        socialSharer.share(socialMessage, shareType: .native(restricted: false), viewController: self)
    }

    private func shareOnFacebook() {
        guard let socialMessage = viewModel.socialMessage else { return }
        socialSharer.share(socialMessage, shareType: .facebook, viewController: self)
    }
}


// MARK: - SocialSharerDelegate

extension ListingPostedViewController: SocialSharerDelegate {
    func shareStartedIn(_ shareType: ShareType) {
        viewModel.shareStartedIn(shareType)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        viewModel.shareFinishedIn(shareType, withState: state)
    }
}


// MARK: - Incentivise methods

extension ListingPostedViewController: PostIncentivatorViewDelegate {

    func incentivatorTapped() {
        viewModel.incentivateSectionPressed()
    }
}


// MARK: - Accesibility

extension ListingPostedViewController {
    func setAccesibilityIds() {
        closeButton.set(accessibilityId: .postingInfoCloseButton)
        shareButton.set(accessibilityId: .postingInfoShareButton)
        loadingIndicator.set(accessibilityId: .postingInfoLoading)
        editButton.set(accessibilityId: .postingInfoEditButton)
        mainButton.set(accessibilityId: .postingInfoMainButton)
        incentiveContainer.set(accessibilityId: .postingInfoIncentiveContainer)
    }
}
