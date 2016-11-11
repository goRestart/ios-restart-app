//
//  SettingsCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SettingsSwitchCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!

    var showBottomBorder = true

    private var lines: [CALayer] = []
    private var switchAction: (Bool -> Void)?

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

    func setupWithSetting(setting: LetGoSetting) {
        label.text = setting.title
        label.textColor = UIColor.darkGrayColor()
        iconImageView.image = setting.image
        settingSwitch.on = setting.switchInitialValue
        switchAction = setting.switchAction
    }

    @IBAction func switchValueChanged(sender: AnyObject) {
        switchAction?(settingSwitch.on)
    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
    }

    private func setupAccessibilityIds() {
        iconImageView.accessibilityId = .SettingsCellIcon
        label.accessibilityId = .SettingsCellTitle
        settingSwitch.accessibilityId = .SettingsCellSwitch
    }
}

private extension LetGoSetting {
    var title: String {
        switch (self) {
        case .MarketingNotifications:
            return LGLocalizedString.settingsMarketingNotificationsSwitch
        default:
            return ""
        }
    }

    var image: UIImage? {
        switch (self) {
        case .MarketingNotifications:
            return UIImage(named: "ic_setting_notifications")
        default:
            return nil
        }
    }

    var switchAction: (Bool -> Void)? {
        switch self {
        case let .MarketingNotifications(_, action):
            return action
        default:
            return nil
        }
    }

    var switchInitialValue: Bool {
        switch self {
        case let .MarketingNotifications(initialValue, _):
            return initialValue
        default:
            return false
        }
    }
}
