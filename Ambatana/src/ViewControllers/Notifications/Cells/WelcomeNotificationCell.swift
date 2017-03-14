//
//  WelcomeNotificationCell.swift
//  LetGo
//
//  Created by Eli Kohen on 06/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class WelcomeNotificationCell: UITableViewCell, ReusableCell {

    static var reusableID = "WelcomeNotificationCell"

    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!


    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }


    // MARK: - Private methods

    private func setupUI() {
        cellContainer.clipsToBounds = true
        cellContainer.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius

        titleLabel.font = UIFont.notificationTitleFont
        subtitleLabel.font = UIFont.notificationSubtitleFont(read: false)

        titleLabel.textColor = UIColor.lgBlack
        subtitleLabel.textColor = UIColor.lgBlack

        actionButton.setStyle(.primary(fontSize: .small))
        actionButton.isUserInteractionEnabled = false
    }

    private func refreshState() {
        let highlighedState = self.isHighlighted || self.isSelected
        cellContainer.alpha = highlighedState ? LGUIKitConstants.highlightedStateAlpha : 1.0
    }
}
