import Foundation
import LGComponents

final class PushPrePermissionsSettingsViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstSectionLabel: UILabel!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var secondSectionLabel: UILabel!
    @IBOutlet weak var allowNotificationsLabel: UILabel!
    @IBOutlet weak var yesButton: LetgoButton!
    @IBOutlet weak var settingsImage1: UIImageView!
    @IBOutlet weak var settingsImage2: UIImageView!

    var completion: (() -> ())?

    let viewModel: PushPrePermissionsSettingsViewModel
    
    // MARK: - Lifecycle
    
    init(viewModel: PushPrePermissionsSettingsViewModel) {
        self.viewModel = viewModel
        
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            super.init(viewModel: viewModel, nibName: "PushPrePermissionsSettingsViewControllerMini",
                       statusBarStyle: .lightContent)
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            super.init(viewModel: viewModel, nibName: "PushPrePermissionsSettingsViewController",
                       statusBarStyle: .lightContent)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupUI()
        setupStrings()
    }


    // MARK: - UI
    
    func setupUI() {
        view.backgroundColor = .clear
        yesButton.setStyle(.primary(fontSize: .medium))
        
        settingsImage1.image = R.Asset.BackgroundsAndImages.settingsNotifications1.image
        settingsImage2.image = R.Asset.BackgroundsAndImages.settingsNotifications2.image

        let close = UIBarButtonItem.init(image: R.Asset.IconsButtons.icClose.image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(closeButtonPressed))
        navigationItem.leftBarButtonItem = close

        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            titleLabel.font = UIFont.tourNotificationsTitleMiniFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            firstSectionLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            secondSectionLabel.font = UIFont.tourNotificationsSubtitleMiniFont
            notificationsLabel.font = UIFont.notificationsSettingsCellTextMiniFont
            allowNotificationsLabel.font = UIFont.notificationsSettingsCellTextMiniFont
        case .iPhone6, .iPhone6Plus, .biggerUnknown:
            titleLabel.font = UIFont.tourNotificationsTitleFont
            subtitleLabel.font = UIFont.tourNotificationsSubtitleFont
            firstSectionLabel.font = UIFont.tourNotificationsSubtitleFont
            secondSectionLabel.font = UIFont.tourNotificationsSubtitleFont
            notificationsLabel.font = UIFont.notificationsSettingsCellTextFont
            allowNotificationsLabel.font = UIFont.notificationsSettingsCellTextFont
        }
    }
    
    func setupStrings() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = R.Strings.notificationsPermissionsSettingsSubtitle
        firstSectionLabel.attributedText = firstSectionAttributedTitle()
        notificationsLabel.text = R.Strings.notificationsPermissionsSettingsCell1
        secondSectionLabel.attributedText = secondSectionAttributedTitle()
        allowNotificationsLabel.text = R.Strings.notificationsPermissionsSettingsCell2
        yesButton.setTitle(R.Strings.notificationsPermissionsSettingsYesButton, for: .normal)
    }
    
    
    func firstSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryColor]
        let title = NSMutableAttributedString(string: "1. ", attributes: attributes)
        let t = NSAttributedString(string: R.Strings.notificationsPermissionsSettingsSection1, attributes: nil)
        title.append(t)
        return title
    }
    
    func secondSectionAttributedTitle() -> NSAttributedString {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.primaryColor]
        let title = NSMutableAttributedString(string: "2. ", attributes: attributes)
        let t = NSAttributedString(string: R.Strings.notificationsPermissionsSettingsSection2, attributes: nil)
        title.append(t)
        return title
    }
    
    
    // MARK: - Actions
    
    @IBAction func yesButtonPressed(_ sender: AnyObject) {
        LGPushPermissionsManager.sharedInstance.openPushNotificationSettings()
        viewModel.userDidTapYesButton()
        close()
    }
    
    @objc func closeButtonPressed(_ sender: AnyObject) {
        viewModel.userDidTapNoButton()
        close()
    }
    
    func close() {
        dismiss(animated: true, completion: completion)
    }
}
