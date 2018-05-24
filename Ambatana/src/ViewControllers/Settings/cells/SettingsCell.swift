import UIKit
import LGComponents

class SettingsCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var disclosureImg: UIImageView!

    var showBottomBorder = true
    private var imageRounded: Bool = false

    var lines: [CALayer] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupAccessibilityIds()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lines.forEach { $0.removeFromSuperlayer() }
        lines.removeAll()
        if showBottomBorder {
            lines.append(contentView.addBottomBorderWithWidth(LGUIKitConstants.onePixelSize, xPosition: 50, color: UIColor.lineGray))
        }
        if imageRounded {
            iconImageView.setRoundedCorners()
        }
    }

    func setupWithSetting(_ setting: LetGoSetting) {
        label.text = setting.title
        label.textColor = setting.textColor
        nameLabel.text = setting.textValue
        iconImageView.image = setting.image
        if let imageUrl = setting.imageURL {
            iconImageView.lg_setImageWithURL(imageUrl)
        }
        iconImageView.contentMode = setting.imageRounded ? .scaleAspectFill : .center
        disclosureImg.isHidden = !setting.showsDisclosure
        imageRounded = setting.imageRounded
        if imageRounded {
            iconImageView.setRoundedCorners()
        }
        setNeedsLayout()
    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
    }

    private func setupAccessibilityIds() {
        iconImageView.set(accessibilityId: .settingsCellIcon)
        label.set(accessibilityId: .settingsCellTitle)
        nameLabel.set(accessibilityId: .settingsCellValue)
    }
}

fileprivate extension LetGoSetting {
    var title: String {
        switch self {
        case .changePhoto:
            return R.Strings.settingsChangeProfilePictureButton
        case .changeUsername:
            return R.Strings.settingsChangeUsernameButton
        case .changeEmail:
            return R.Strings.settingsChangeEmailButton
        case .changeLocation:
            return R.Strings.settingsChangeLocationButton
        case .changePassword:
            return R.Strings.settingsChangePasswordButton
        case .marketingNotifications:
            return R.Strings.settingsMarketingNotificationsSwitch
        case .help:
            return R.Strings.settingsHelpButton
        case .termsAndConditions:
            return R.Strings.mainSignUpTermsConditionsTermsPart
        case .privacyPolicy:
            return R.Strings.helpTermsConditionsPrivacyPart
        case .logOut:
            return R.Strings.settingsLogoutButton
        case .versionInfo:
            return ""
        case .changeUserBio:
            return R.Strings.settingsChangeUserBioButton
        case .notifications:
            return R.Strings.settingsNotificationsButton
        }
    }

    var image: UIImage? {
        switch self {
        case .changeUsername:
            return UIImage(named: "ic_setting_name")
        case .changeEmail:
            return UIImage(named: "ic_setting_email")
        case .changeLocation:
            return UIImage(named: "ic_setting_location")
        case .changePassword:
            return UIImage(named: "ic_setting_password")
        case .marketingNotifications:
            return UIImage(named: "ic_setting_notifications")
        case .help:
            return UIImage(named: "ic_setting_help")
        case .termsAndConditions:
            return UIImage(named: "ic_setting_terms_and_conditions")
        case .privacyPolicy:
            return UIImage(named: "ic_setting_privacy_policy")
        case .changeUserBio:
            return UIImage(named: "ic_settings_bio")
        case .logOut, .versionInfo:
            return nil
        case let .changePhoto(placeholder,_):
            return placeholder
        case .notifications:
            return UIImage(named: "ic_setting_notifications")
        }
    }

    var imageURL: URL? {
        switch self {
        case let .changePhoto(_,avatarUrl):
            return avatarUrl
        default:
            return nil
        }
    }

    var imageRounded: Bool {
        switch self {
        case .changePhoto:
            return true
        default:
            return false
        }
    }

    var textColor: UIColor {
        switch (self) {
        case .logOut:
            return UIColor.lightGray
        default:
            return UIColor.darkGray
        }
    }

    var textValue: String? {
        switch self {
        case let .changeUsername(name):
            return name
        case let .changeEmail(email):
            return email
        case let .changeLocation(location):
            return location
        default:
            return nil
        }
    }

    var showsDisclosure: Bool {
        switch self {
        case .logOut, .marketingNotifications:
            return false
        default:
            return true
        }
    }

    var switchMode: Bool {
        switch self {
        case .marketingNotifications:
            return true
        default:
            return false
        }
    }
}
