//
//  SettingsCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var disclosureImg: UIImageView!

    var showBottomBorder = true

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
        iconImageView.rounded = setting.imageRounded
        disclosureImg.isHidden = !setting.showsDisclosure


    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
    }

    private func setupAccessibilityIds() {
        iconImageView.accessibilityId = .settingsCellIcon
        label.accessibilityId = .settingsCellTitle
        nameLabel.accessibilityId = .settingsCellValue
    }
}

fileprivate extension LetGoSetting {
    var title: String {
        switch (self) {
        case .inviteFbFriends:
            return LGLocalizedString.settingsInviteFacebookFriendsButton
        case .changePhoto:
            return LGLocalizedString.settingsChangeProfilePictureButton
        case .changeUsername:
            return LGLocalizedString.settingsChangeUsernameButton
        case .changeLocation:
            return LGLocalizedString.settingsChangeLocationButton
        case .createCommercializer:
            return LGLocalizedString.commercializerCreateFromSettings
        case .changePassword:
            return LGLocalizedString.settingsChangePasswordButton
        case .marketingNotifications:
            return LGLocalizedString.settingsMarketingNotificationsSwitch
        case .help:
            return LGLocalizedString.settingsHelpButton
        case .logOut:
            return LGLocalizedString.settingsLogoutButton
        case .versionInfo:
            return ""
        }
    }

    var image: UIImage? {
        switch (self) {
        case .inviteFbFriends:
            return UIImage(named: "ic_setting_share_fb")
        case .changeUsername:
            return UIImage(named: "ic_setting_name")
        case .changeLocation:
            return UIImage(named: "ic_setting_location")
        case .createCommercializer:
            return UIImage(named: "ic_setting_create_commercial")
        case .changePassword:
            return UIImage(named: "ic_setting_password")
        case .marketingNotifications:
            return UIImage(named: "ic_setting_notifications")
        case .help:
            return UIImage(named: "ic_setting_help")
        case .logOut, .versionInfo:
            return nil
        case let .changePhoto(placeholder,_):
            return placeholder
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
        case .createCommercializer:
            return UIColor.primaryColor
        default:
            return UIColor.darkGray
        }
    }

    var textValue: String? {
        switch self {
        case let .changeUsername(name):
            return name
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
