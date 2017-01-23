//
//  SettingsCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsSwitchCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!

    var showBottomBorder = true

    private var lines: [CALayer] = []
    private var switchAction: ((Bool) -> Void)?
    private let disposeBag = DisposeBag()

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
        setting.switchValue.asObservable().bindTo(settingSwitch.rx.value).addDisposableTo(disposeBag)
        switchAction = setting.switchAction
    }
    
    @IBAction func switchValueChanged(_ sender: AnyObject) {
        switchAction?(settingSwitch.isOn)
    }

    private func setupUI() {
        iconImageView.clipsToBounds = true
    }

    private func setupAccessibilityIds() {
        iconImageView.accessibilityId = .settingsCellIcon
        label.accessibilityId = .settingsCellTitle
        settingSwitch.accessibilityId = .settingsCellSwitch
    }

}

fileprivate extension LetGoSetting {
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

    var switchValue: Variable<Bool> {
        switch self {
        case let .marketingNotifications(switchValue, _):
            return switchValue
        default:
            return Variable<Bool>(false)
        }
    }
}
