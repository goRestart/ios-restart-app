import Foundation
import LGCoreKit
import LGComponents

final class TourLocationViewController: BaseViewController {
    private static let iphone5InfoHeight: CGFloat = 210
    private static let iphone4InfoHeight: CGFloat = 200

    let viewModel: TourLocationViewModel

    @IBOutlet weak var yesButton: LetgoButton!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneBckgImage: UIImageView!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertOkLabel: UILabel!
    @IBOutlet weak var iPhoneTopImage: UIImageView!
    @IBOutlet weak var iPhoneLeftImage: UIImageView!
    @IBOutlet weak var iPhoneRightImage: UIImageView!
    @IBOutlet weak var iPhoneBottomImage: UIImageView!
    @IBOutlet weak var permissionAlertImage: UIImageView!
    
    
    // MARK: - Lifecycle

    init(viewModel: TourLocationViewModel) {
        self.viewModel = viewModel
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: nil,
                       nibName: "TourLocationViewControllerMini",
                       statusBarStyle: .lightContent,
                       navBarBackgroundStyle: .transparent(substyle: .dark))
        case .iPhone5, .iPhone6, .iPhone6Plus, .biggerUnknown:
            super.init(viewModel: nil,
                       nibName: String(describing: TourLocationViewController.self),
                       statusBarStyle: .lightContent,
                       navBarBackgroundStyle: .transparent(substyle: .dark))
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIds()
        viewModel.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        labelContainer.setRoundedCorners()
    }

    func close() {
        let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertYes),
                                action: { [weak self] in
                                    self?.viewModel.okAlertTapped() })
        let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertNo),
                                    action: { [weak self] in
                                        self?.viewModel.cancelAlertTapped() })
        showAlert(R.Strings.onboardingLocationPermissionsAlertTitle,
                  message: R.Strings.onboardingLocationPermissionsAlertSubtitle,
                  actions: [actionCancel, actionOk])
    }

    
    // MARK: - IBActions
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        viewModel.userDidTapYesButton()
    }
    
    @objc private func noButtonPressed(_ sender: AnyObject) {
        close()
    }

    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        close()
    }
    
    
    // MARK: - Private
    
    private func setupUI() {
        view.backgroundColor = .clear
        setupImages()
        titleLabel.text = viewModel.title
        subtitleLabel.text = R.Strings.locationPermissonsSubtitle
        distanceLabel.text = R.Strings.locationPermissionsBubble

        iphoneBckgImage.image = viewModel.infoImage
        yesButton.setTitle(R.Strings.locationPermissionsButton, for: .normal)
        yesButton.setStyle(.primary(fontSize: .medium))

        distanceLabel.font = UIFont.tourLocationDistanceLabelFont
        distanceLabel.textColor = UIColor.lgBlack
        alertOkLabel.text = R.Strings.locationPermissionsAllowButton
        
        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourLocationViewController.iphone4InfoHeight
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourLocationViewController.iphone5InfoHeight
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }

        labelContainer.isHidden = !viewModel.showBubbleInfo
        alertContainer.isHidden = !viewModel.showAlertInfo
        let tap = UITapGestureRecognizer(target: self, action: #selector(yesButtonPressed(_:)))
        alertContainer.addGestureRecognizer(tap)

        let close = UIBarButtonItem.init(image: R.Asset.IconsButtons.icClose.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeButtonPressed))
        close.set(accessibilityId: .tourLocationCloseButton)
        navigationItem.leftBarButtonItem = close
    }

    private func setupImages() {
        iPhoneTopImage.image = R.Asset.IPhoneParts.iphoneTop.image
        iPhoneLeftImage.image = R.Asset.IPhoneParts.iphoneLeft.image
        iPhoneRightImage.image = R.Asset.IPhoneParts.iphoneRight.image
        iphoneBckgImage.image = R.Asset.BackgroundsAndImages.tour1.image
        iPhoneBottomImage.image = R.Asset.IPhoneParts.iphoneBottom.image
        permissionAlertImage.image = R.Asset.IPhoneParts.imgPermissionsAlert.image
    }
    
    private func setupAccessibilityIds() {
        yesButton.set(accessibilityId: .tourLocationOKButton)
        alertContainer.set(accessibilityId: .tourLocationAlert)
    }
}
