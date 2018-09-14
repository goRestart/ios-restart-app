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
        disclosureImg.image = R.Asset.IconsButtons.icDisclosure.image
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
        case .affiliation:
            return R.Strings.settingsAffililationButton
        }
    }

    var image: UIImage? {
        switch self {
        case .changeUsername:
            return R.Asset.IconsButtons.icSettingName.image
        case .changeEmail:
            return R.Asset.IconsButtons.icSettingEmail.image
        case .changeLocation:
            return R.Asset.IconsButtons.icSettingLocation.image
        case .changePassword:
            return R.Asset.IconsButtons.icSettingPassword.image
        case .help:
            return R.Asset.IconsButtons.icSettingHelp.image
        case .termsAndConditions:
            return R.Asset.IconsButtons.icSettingTermsAndConditions.image
        case .privacyPolicy:
            return R.Asset.IconsButtons.icSettingPrivacyPolicy.image
        case .changeUserBio:
            return R.Asset.IconsButtons.icSettingsBio.image
        case .logOut, .versionInfo:
            return nil
        case let .changePhoto(placeholder,_):
            return placeholder
        case .notifications:
            return R.Asset.IconsButtons.icSettingNotifications.image
        case .affiliation:
            return R.Asset.IconsButtons.icSettingAffiliation.image
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
        case .logOut:
            return false
        default:
            return true
        }
    }
}
