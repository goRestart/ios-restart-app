//
//  BuyersInterestedNotificationCell.swift
//  LetGo
//
//  Created by Albert Hernández on 23/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class BuyersInterestedNotificationCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var primaryImage: UIImageView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet var userImageViews: [UIImageView]!


    var primaryImageAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        resetUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resetUI()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }

    // MARK: > Actions

    @IBAction func primaryImagePressed(_ sender: AnyObject) {
        primaryImageAction?()
    }

    
    // MARK: - Private methods

    private func setupUI() {
        cellContainer.clipsToBounds = true
        cellContainer.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius

        primaryImage.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        timeLabel.font = UIFont.notificationTimeFont
        actionLabel.font = UIFont.notificationSubtitleFont

        actionLabel.textColor = UIColor.black
        timeLabel.textColor = UIColor.black
        primaryImage.backgroundColor = UIColor.placeholderBackgroundColor()

        primaryImage.accessibilityId = .NotificationsCellPrimaryImage

        actionButton.isUserInteractionEnabled = false
        actionButton.setStyle(.secondary(fontSize: .small, withBorder: true))

        userImageViews.forEach { $0.rounded = true }
    }

    private func resetUI() {
        primaryImage.image = nil
        iconImage.image = nil
        actionLabel.text = nil
        timeLabel.text = nil
        primaryImageAction = nil
    }

    private func refreshState() {
        let highlighedState = self.isHighlighted || self.isSelected
        cellContainer.alpha = highlighedState ? LGUIKitConstants.highlightedStateAlpha : 1.0
    }
}
