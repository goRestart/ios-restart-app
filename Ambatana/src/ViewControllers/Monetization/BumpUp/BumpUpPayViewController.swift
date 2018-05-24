import UIKit
import LGComponents

final class BumpUpPayViewController: BaseViewController {

    @IBOutlet weak var titleSafeAreaTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewTitleLabel: UILabel!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var featuredBackgroundImageView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var cellBottomContainer: UIView!
    @IBOutlet weak var bumpUpButton: LetgoButton!

    private let viewModel: BumpUpPayViewModel

    // MARK: - Init
    
    init(viewModel: BumpUpPayViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BumpUpPayViewController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()
        addSwipeDownGestureToView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderContainerCornerRadius()
    }
    
    // MARK: - Actions
    
    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    @IBAction func bumpUpButtonPressed(_ sender: AnyObject) {
        viewModel.bumpUpPressed()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        setupInfoContainer()
        setupImageContainer()
        setupCellBottomContainer()
        setupImageView()
        setupLabels()
        setupBumpUpButton()
        adjustViewTopSafeArea()
    }
    
    private func renderContainerCornerRadius() {
        infoContainer.cornerRadius = LGUIKitConstants.bigCornerRadius
        imageContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }
    
    private func setupLabels() {
        titleLabel.text = R.Strings.bumpUpViewPayTitle
        subtitleLabel.text = R.Strings.bumpUpViewPaySubtitle
        if FeatureFlags.sharedInstance.shouldChangeSellFasterNowCopyInEnglish {
            viewTitleLabel.text = FeatureFlags.sharedInstance.copyForSellFasterNowInEnglish.variantString
        } else {
            viewTitleLabel.text = R.Strings.bumpUpBannerPayTextImprovement
        }
    }
    
    private func setupCellBottomContainer() {
        cellBottomContainer.clipsToBounds = true
        cellBottomContainer.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }
    
    private func setupInfoContainer() {
        infoContainer.layer.masksToBounds = false
        infoContainer.applyShadow(withOpacity: 0.05, radius: 5)
    }
    
    private func setupImageContainer() {
        imageContainer.layer.masksToBounds = false
        imageContainer.applyShadow(withOpacity: 0.25, radius: 5)
        
        if let imageUrl = viewModel.listing.images.first?.fileURL {
            listingImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: { [weak self] (result, _) -> Void in
                self?.imageContainer.isHidden = result.value == nil
            })
        } else {
            imageContainer.isHidden = true
        }
    }

    private func setupImageView() {
        listingImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }
    
    private func setupBumpUpButton() {
        bumpUpButton.setStyle(.primary(fontSize: .big))
        bumpUpButton.setTitle(R.Strings.bumpUpViewPayButtonTitle(viewModel.price), for: .normal)
        bumpUpButton.titleLabel?.numberOfLines = 2
        bumpUpButton.titleLabel?.adjustsFontSizeToFitWidth = true
        bumpUpButton.titleLabel?.minimumScaleFactor = 0.8
    }
    
    private func adjustViewTopSafeArea() {
        if !isSafeAreaAvailable {
            titleSafeAreaTopConstraint.constant = Metrics.veryBigMargin
        }
    }
    
    private func addSwipeDownGestureToView() {
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }

    private func setAccessibilityIds() {
        closeButton.set(accessibilityId: .paymentBumpUpCloseButton)
        listingImageView.set(accessibilityId: .paymentBumpUpImage)
        titleLabel.set(accessibilityId: .paymentBumpUpTitleLabel)
        subtitleLabel.set(accessibilityId: .paymentBumpUpSubtitleLabel)
        bumpUpButton.set(accessibilityId: .paymentBumpUpButton)
    }
}
