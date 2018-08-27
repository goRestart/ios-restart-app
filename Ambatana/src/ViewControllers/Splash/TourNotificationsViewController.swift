import Foundation
import LGCoreKit
import LGComponents

final class TourNotificationsViewController: BaseViewController {

    private static let iphone5InfoHeight: CGFloat = 210
    private static let iphone4InfoHeight: CGFloat = 200

    let viewModel: TourNotificationsViewModel

    @IBOutlet weak var notifyButton: LetgoButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iphoneRightHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iphoneBckgImage: UIImageView!
    @IBOutlet weak var pushContainer: UIView!
    @IBOutlet weak var notificationTimeLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var alertContainer: UIView!
    @IBOutlet weak var alertOkLabel: UILabel!
    @IBOutlet weak var iPhoneTopImage: UIImageView!
    @IBOutlet weak var iPhoneLeftImage: UIImageView!
    @IBOutlet weak var iPhoneRightImage: UIImageView!
    @IBOutlet weak var iPhoneBottomImage: UIImageView!
    @IBOutlet weak var pushImage: UIImageView!
    @IBOutlet weak var permissionAlertImage: UIImageView!

    var completion: (() -> ())?
    var pushDialogWasShown = false

    // MARK: - Lifecycle
    
    init(viewModel: TourNotificationsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4:
            super.init(viewModel: viewModel,
                       nibName: "TourNotificationsViewControllerMini",
                       statusBarStyle: .lightContent,
                       navBarBackgroundStyle: .transparent(substyle: .dark))
        case .iPhone5, .iPhone6, .iPhone6Plus, .biggerUnknown:
            super.init(viewModel: viewModel,
                       nibName: String(describing: TourNotificationsViewController.self),
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
        setupTexts()

        let close = UIBarButtonItem.init(image: R.Asset.IconsButtons.icClose.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeButtonPressed))
        close.set(accessibilityId: .tourNotificationsCloseButton)
        navigationItem.leftBarButtonItem = close

        NotificationCenter.default.addObserver(self,
            selector: #selector(TourNotificationsViewController.didRegisterUserNotificationSettings),
            name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        viewModel.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func didRegisterUserNotificationSettings() {
        let time = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            guard let viewAlpha = self?.view.alpha, viewAlpha > 0 else { return }
            self?.viewModel.openNextStep()
        }
    }
    
    @objc func didBecomeActive() {
        guard pushDialogWasShown else { return }
        viewModel.openNextStep()
    }
    
    // MARK: - IBActions
    
    @objc private func closeButtonPressed(_ sender: AnyObject) {
        noButtonPressed(sender)
    }
   
    @IBAction func noButtonPressed(_ sender: AnyObject) {
        let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertYes),
                                action: { [weak self] in
                                    self?.viewModel.okAlertTapped()

        })
        let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertNo),
                                    action: { [weak self] in
                                        self?.viewModel.cancelAlertTapped()

        })
        showAlert(R.Strings.onboardingNotificationsPermissionsAlertTitle,
                  message: R.Strings.onboardingNotificationsPermissionsAlertSubtitle,
                  actions: [actionCancel, actionOk])
    }
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        viewModel.userDidTapYesButton()
        pushDialogWasShown = true
    }    
    
    // MARK: - UI
    
    func setupTexts() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        notificationMessageLabel.text = viewModel.pushText
        
        notifyButton.setTitle(R.Strings.notificationsPermissionsYesButton, for: .normal)
        notificationTimeLabel.text = R.Strings.commonTimeNowLabel

        alertOkLabel.text = R.Strings.commonOk
    }
    
    func setupUI() {
        view.backgroundColor = .clear
        setupImages()
        iphoneBckgImage.image = viewModel.infoImage
        notifyButton.setStyle(.primary(fontSize: .medium))

        switch DeviceFamily.current {
        case .iPhone4:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourNotificationsViewController.iphone4InfoHeight
        case .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            iphoneRightHeightConstraint.constant = TourNotificationsViewController.iphone5InfoHeight
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
        }

        pushContainer.isHidden = !viewModel.showPushInfo
        alertContainer.isHidden = !viewModel.showAlertInfo
        let tap = UITapGestureRecognizer(target: self, action: #selector(yesButtonPressed(_:)))
        alertContainer.addGestureRecognizer(tap)
    }
    
    private func setupImages() {
        iPhoneTopImage.image = R.Asset.IPhoneParts.iphoneTop.image
        iPhoneLeftImage.image = R.Asset.IPhoneParts.iphoneLeft.image
        iPhoneRightImage.image = R.Asset.IPhoneParts.iphoneRight.image
        iphoneBckgImage.image = R.Asset.IPhoneParts.imgNotifications.image
        iPhoneBottomImage.image = R.Asset.IPhoneParts.iphoneBottom.image
        pushImage.image = R.Asset.IPhoneParts.imgPush.image
        permissionAlertImage.image = R.Asset.IPhoneParts.imgPermissionsAlert.image
    }

    func setupAccessibilityIds() {
        notifyButton.set(accessibilityId: .tourNotificationsOKButton)
        alertContainer.set(accessibilityId: .tourNotificationsAlert)
    }
}
