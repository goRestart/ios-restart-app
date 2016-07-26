//
//  SettingsCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    private func resetUI() {
        iconImageView.image = nil
        label.text = nil
        nameLabel.text = nil
        accessoryType = .DisclosureIndicator
    }
    
}
