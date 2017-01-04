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
    private var switchAction: ((Bool) -> Void)?

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
        label.textColor = UIColor.darkGray
        iconImageView.image = setting.image
        settingSwitch.isOn = setting.switchInitialValue
        switchAction = setting.switchAction
    }

    @IBAction func switchValueChanged(_ sender: AnyObject) {
        switchAction?(settingSwitch.isOn)
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
        case .marketingNotifications:
            return LGLocalizedString.settingsMarketingNotificationsSwitch
        default:
            return ""
        }
    }

    var image: UIImage? {
        switch (self) {
        case .marketingNotifications:
            return UIImage(named: "ic_setting_notifications")
        default:
            return nil
        }
    }

    var switchAction: ((Bool) -> Void)? {
        switch self {
        case let .marketingNotifications(_, action):
            return action
        default:
            return nil
        }
    }

    var switchInitialValue: Bool {
        switch self {
        case let .marketingNotifications(initialValue, _):
            return initialValue
        default:
            return false
        }
    }
}
