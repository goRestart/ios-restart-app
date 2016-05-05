//
//  NotificationCell.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell, ReusableCell {

    static let cellHeight: CGFloat = 74
    static var reusableID = "NotificationCell"

    @IBOutlet weak var primaryImage: UIImageView!
    @IBOutlet weak var secondaryImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    private var lines: [CALayer] = []

    var primaryImageAction: (()->Void)?
    var secondaryImageAction: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
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


    // MARK: > Actions

    @IBAction func primaryImagePressed(sender: AnyObject) {
        primaryImageAction?()
    }

    @IBAction func secondaryImagePressed(sender: AnyObject) {
        secondaryImageAction?()
    }

    
    // MARK: - Private methods

    private func setupUI() {
        secondaryImage.layer.cornerRadius = StyleHelper.defaultCornerRadius
        secondaryImage.backgroundColor = StyleHelper.notificationCellImageBgColor
        primaryImage.layer.cornerRadius = primaryImage.width/2
        primaryImage.clipsToBounds = true
        titleLabel.font = StyleHelper.notificationTitleFont
        timeLabel.font = StyleHelper.notificationTimeFont
        actionLabel.font = StyleHelper.notificationSubtitleFont

        titleLabel.textColor = StyleHelper.notificationTitleColor
        actionLabel.textColor = StyleHelper.notificationSubtitleColor
        timeLabel.textColor = StyleHelper.notificationTimeColor
        primaryImage.backgroundColor = StyleHelper.notificationCellImageBgColor
        iconImage.layer.cornerRadius = iconImage.height/2
    }

    private func resetUI() {
        primaryImage.image = nil
        secondaryImage.image = nil
        iconImage.image = nil
        titleLabel.text = nil
        actionLabel.text = nil
        timeLabel.text = nil
        primaryImageAction = nil
        secondaryImageAction = nil
    }
}
