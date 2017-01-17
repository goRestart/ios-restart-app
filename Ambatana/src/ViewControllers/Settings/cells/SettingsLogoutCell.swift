//
//  SettingsLogoutCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SettingsLogoutCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var logoutButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        logoutButton.isHighlighted = highlighted
    }

    private func setupUI() {
        logoutButton.isUserInteractionEnabled = false
        logoutButton.setStyle(.logout)
        logoutButton.layer.cornerRadius = 22
        logoutButton.setTitle(LGLocalizedString.settingsLogoutButton, for: .normal)
    }
}
