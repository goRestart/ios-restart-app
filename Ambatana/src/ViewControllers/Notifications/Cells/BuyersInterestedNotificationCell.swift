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

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        refreshState()
    }

    // MARK: > Actions

    @IBAction func primaryImagePressed(sender: AnyObject) {
        primaryImageAction?()
    }

    
    // MARK: - Private methods

    private func setupUI() {
        cellContainer.clipsToBounds = true
        cellContainer.layer.cornerRadius = LGUIKitConstants.notificationCellCornerRadius

        primaryImage.rounded = true
        timeLabel.font = UIFont.notificationTimeFont
        actionLabel.font = UIFont.notificationSubtitleFont

        actionLabel.textColor = UIColor.black
        timeLabel.textColor = UIColor.black
        primaryImage.backgroundColor = UIColor.placeholderBackgroundColor()

        primaryImage.accessibilityId = .NotificationsCellPrimaryImage

        actionButton.userInteractionEnabled = false
        actionButton.setStyle(.Secondary(fontSize: .Small, withBorder: false))
        actionButton.contentEdgeInsets = UIEdgeInsets() //Resetting edge insets to align left
    }

    private func resetUI() {
        primaryImage.image = nil
        iconImage.image = nil
        actionLabel.text = nil
        timeLabel.text = nil
        primaryImageAction = nil
    }

    private func refreshState() {
        let highlighedState = self.highlighted || self.selected
        cellContainer.alpha = highlighedState ? 0.6 : 1.0
    }
}
