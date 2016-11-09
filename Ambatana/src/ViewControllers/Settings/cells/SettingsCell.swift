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
        if showBottomBorder {
            // Redraw the lines
            lines.forEach { $0.removeFromSuperlayer() }
            lines.removeAll()
            lines.append(contentView.addBottomBorderWithWidth(LGUIKitConstants.onePixelSize, xPosition: 50, color: UIColor.lineGray))
        }
    }

    func setupWithSetting(setting: LetGoSetting) {
        label.text = setting.title
        label.textColor = setting.textColor
        nameLabel.text = setting.textValue
        iconImageView.image = setting.image
        if let imageUrl = setting.imageURL {
            iconImageView.lg_setImageWithURL(imageUrl)
        }
        iconImageView.contentMode = setting.imageRounded ? .ScaleAspectFill : .Center
        iconImageView.rounded = setting.imageRounded
        disclosureImg.hidden = !setting.showsDisclosure
    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
    }

    private func setupAccessibilityIds() {
        iconImageView.accessibilityId = .SettingsCellIcon
        label.accessibilityId = .SettingsCellTitle
        nameLabel.accessibilityId = .SettingsCellValue
    }
}

private extension LetGoSetting {
    var title: String {
        switch (self) {
        case .InviteFbFriends:
            return LGLocalizedString.settingsInviteFacebookFriendsButton
        case .ChangePhoto:
            return LGLocalizedString.settingsChangeProfilePictureButton
        case .ChangeUsername:
            return LGLocalizedString.settingsChangeUsernameButton
        case .ChangeLocation:
            return LGLocalizedString.settingsChangeLocationButton
        case .CreateCommercializer:
            return LGLocalizedString.commercializerCreateFromSettings
        case .ChangePassword:
            return LGLocalizedString.settingsChangePasswordButton
        case .Help:
            return LGLocalizedString.settingsHelpButton
        case .LogOut:
            return LGLocalizedString.settingsLogoutButton
        case .VersionInfo:
            return ""
        }
    }

    var image: UIImage? {
        switch (self) {
        case .InviteFbFriends:
            return UIImage(named: "ic_setting_share_fb")
        case .ChangeUsername:
            return UIImage(named: "ic_setting_name")
        case .ChangeLocation:
            return UIImage(named: "ic_setting_location")
        case .CreateCommercializer:
            return UIImage(named: "ic_setting_create_commercial")
        case .ChangePassword:
            return UIImage(named: "ic_setting_password")
        case .Help:
            return UIImage(named: "ic_setting_help")
        case .LogOut, .VersionInfo:
            return nil
        case let .ChangePhoto(placeholder,_):
            return placeholder
        }
    }

    var imageURL: NSURL? {
        switch self {
        case let .ChangePhoto(_,avatarUrl):
            return avatarUrl
        default:
            return nil
        }
    }

    var imageRounded: Bool {
        switch self {
        case .ChangePhoto:
            return true
        default:
            return false
        }
    }

    var textColor: UIColor {
        switch (self) {
        case .LogOut:
            return UIColor.lightGrayColor()
        case .CreateCommercializer:
            return UIColor.primaryColor
        default:
            return UIColor.darkGrayColor()
        }
    }

    var textValue: String? {
        switch self {
        case let .ChangeUsername(name):
            return name
        case let .ChangeLocation(location):
            return location
        default:
            return nil
        }
    }

    var showsDisclosure: Bool {
        switch self {
        case .LogOut:
            return false
        default:
            return true
        }
    }
}
