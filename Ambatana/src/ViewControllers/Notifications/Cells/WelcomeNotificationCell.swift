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
        self.setupUI()
    }
    

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }


    // MARK: - Private methods

    private func setupUI() {
        cellContainer.clipsToBounds = true
        cellContainer.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius

        titleLabel.font = UIFont.notificationTitleFont
        subtitleLabel.font = UIFont.notificationSubtitleFont

        titleLabel.textColor = UIColor.blackText
        subtitleLabel.textColor = UIColor.darkGrayText

        actionButton.setStyle(.Primary(fontSize: .Small))
        actionButton.userInteractionEnabled = false
        actionButton.setTitle(LGLocalizedString.notificationsTypeWelcomeButton, forState: .Normal)
    }

    private func refreshState() {
        let highlighedState = self.highlighted || self.selected
        cellContainer.backgroundColor = highlighedState ? UIColor.grayLighter : UIColor.white
    }
}
