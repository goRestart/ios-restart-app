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

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupAccessibilityIds()
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
        iconImageView.layer.cornerRadius = setting.imageRounded ? iconImageView.frame.size.width / 2.0 : 0.0
        accessoryType = setting.showsDisclosure ? .DisclosureIndicator : .None
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
