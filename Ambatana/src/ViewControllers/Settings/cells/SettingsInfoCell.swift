//
//  SettingsInfoCell.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class SettingsInfoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var infoLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func refreshData() {
        if let version = VersionChecker.sharedInstance.currentVersion.version {
            infoLabel.text = "v"+version
        } else {
            infoLabel.text = nil
        }
    }
}
