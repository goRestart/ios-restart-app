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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private var lines: [CALayer] = []


    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }


    // MARK: - Private methods

    private func setupUI() {
        titleLabel.font = StyleHelper.notificationTitleFont
        subtitleLabel.font = StyleHelper.notificationSubtitleFont

        titleLabel.textColor = StyleHelper.notificationTitleColor
        subtitleLabel.textColor = StyleHelper.notificationSubtitleColor
    }
}
