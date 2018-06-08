import UIKit
import LGComponents

final class BumpUpFreeViewController: BaseViewController {

    private static let shareButtonWidth: CGFloat = 60
    private static let titleVerticalOffsetWithImage: CGFloat = 50
    private static let titleVerticalOffsetWithoutImage: CGFloat = -100

    @IBOutlet weak var bottomCloudImageView: UIImageView!
    @IBOutlet weak var topCloudImageView: UIImageView!
    @IBOutlet weak var searchAlertImageView: UIImageView!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var listingImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var shareButtonsContainer: UIView!
    @IBOutlet weak var socialShareView: SocialShareView!

    @IBOutlet weak var  titleVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var  shareButtonsContainerWidth: NSLayoutConstraint!

    private var viewModel: BumpUpFreeViewModel

    
    // MARK: - Lifecycle

    init(viewModel: BumpUpFreeViewModel) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, nibName: "BumpUpFreeViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccessibilityIds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidApear()
    }

    // MARK: private methods

    func setupUI() {
        if let imageUrl = viewModel.listing.images.first?.fileURL {
            listingImageView.lg_setImageWithURL(imageUrl, placeholderImage: nil, completion: {
                [weak self] (result, url) -> Void in
                if let _ = result.value {
                    self?.titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithImage
                    self?.imageContainer.isHidden = false
                } else {
                    self?.titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithoutImage
                    self?.imageContainer.isHidden = true
                }
            })
        } else {
            titleVerticalCenterConstraint.constant = BumpUpFreeViewController.titleVerticalOffsetWithoutImage
            imageContainer.isHidden = true
        }

        listingImageView.cornerRadius = LGUIKitConstants.mediumCornerRadius
        shareButtonsContainerWidth.constant = CGFloat(viewModel.shareTypes.count)*BumpUpFreeViewController.shareButtonWidth
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        setupShareView()

        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(gestureClose))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)

        setupRAssets()
    }

    private func setupRAssets() {
        topCloudImageView.image = R.Asset.Monetization.cloud.image
        bottomCloudImageView.image = R.Asset.Monetization.cloud.image
        closeButton.setImage(R.Asset.Monetization.redChevronDown.image, for: .normal)
    }

    private func setupShareView() {
        socialShareView.socialMessage = viewModel.socialMessage
        socialShareView.setupWithShareTypes(viewModel.shareTypes, useBigButtons: true)
        socialShareView.socialSharer = viewModel.socialSharer
        socialShareView.delegate = self
        socialShareView.buttonsSide = BumpUpFreeViewController.shareButtonWidth
        socialShareView.style = .line
    }

    @objc private dynamic func gestureClose() {
        viewModel.closeActionPressed()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        viewModel.closeActionPressed()
    }

    private func setAccessibilityIds() {
        closeButton.set(accessibilityId: .freeBumpUpCloseButton)
        listingImageView.set(accessibilityId: .freeBumpUpImage)
        titleLabel.set(accessibilityId: .freeBumpUpTitleLabel)
        subtitleLabel.set(accessibilityId: .freeBumpUpSubtitleLabel)
        socialShareView.set(accessibilityId: .freeBumpUpSocialShareView)
    }
}

extension BumpUpFreeViewController: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return self
    }
}
