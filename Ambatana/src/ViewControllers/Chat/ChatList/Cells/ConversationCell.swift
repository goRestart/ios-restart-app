//
//  ConversationCell.swift
//  LetGo
//
//  Created by AHL on 25/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

enum ConversationCellStatus {
    case Available
    case Forbidden
    case Sold
    case Deleted
}

struct ConversationCellData {
    let status: ConversationCellStatus
    let userName: String
    let userImageUrl: NSURL?
    let userImagePlaceholder: UIImage
    let productName: String
    let productImageUrl: NSURL?
    let unreadCount: Int
    let messageDate: NSDate?
}

class ConversationCell: UITableViewCell, ReusableCell {

    static var reusableID = "ConversationCell"

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var separationStatusImageToTimeLabel: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!

    static let defaultHeight: CGFloat = 76
    private static let statusImageDefaultMargin: CGFloat = 4

    private var lines: [CALayer] = []


    // MARK: - Lifecycle

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
        lines.append(contentView.addBottomBorderWithWidth(1, color: UIColor.lineGray))
    }


    // MARK: - Overrides

    override func setSelected(selected: Bool, animated: Bool) {
        if (selected && !editing) {
            super.setSelected(false, animated: animated)
        } else {
            super.setSelected(selected, animated: animated)
        }
    }


    // MARK: - Public methods

    func setupCellWithData(data: ConversationCellData, indexPath: NSIndexPath) {
        let tag = indexPath.hash

        // thumbnail
        if let thumbURL = data.productImageUrl {
            thumbnailImageView.lg_setImageWithURL(thumbURL) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image where self?.tag == tag {
                    self?.thumbnailImageView.image = image
                }
            }
        }
        avatarImageView.image = data.userImagePlaceholder
        if let avatarURL = data.userImageUrl {
            avatarImageView.lg_setImageWithURL(avatarURL, placeholderImage: data.userImagePlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image where self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }

        productLabel.text = data.productName
        userLabel.text = data.userName

        if data.unreadCount > 0 {
            timeLabel.font = UIFont.conversationTimeUnreadFont
            productLabel.font = UIFont.conversationProductUnreadFont
            userLabel.font = UIFont.conversationUserNameUnreadFont
        } else {
            timeLabel.font = UIFont.conversationTimeFont
            productLabel.font = UIFont.conversationProductFont
            userLabel.font = UIFont.conversationUserNameFont
        }

        switch data.status {
        case .Forbidden:
            timeLabel.text = LGLocalizedString.accountDeactivated
            statusImageView.image = UIImage(named: "ic_alert_yellow_white_inside")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        case .Sold:
            timeLabel.text = LGLocalizedString.commonProductSold
            statusImageView.image = UIImage(named: "ic_dollar_sold")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        case .Deleted:
            timeLabel.text = LGLocalizedString.commonProductNotAvailable
            statusImageView.image = UIImage(named: "ic_alert_yellow_white_inside")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        case .Available:
            timeLabel.text = data.messageDate?.relativeTimeString(false) ?? ""
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        }

        let badge: String? = data.unreadCount > 0 ? String(data.unreadCount) : nil
        badgeLabel.text = badge
        badgeView.hidden = (badge == nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        productLabel.font = UIFont.conversationProductFont
        userLabel.font = UIFont.conversationUserNameFont
        timeLabel.font = UIFont.conversationTimeFont

        productLabel.textColor = UIColor.darkGrayText
        userLabel.textColor = UIColor.blackText
        timeLabel.textColor = UIColor.darkGrayText
        thumbnailImageView.backgroundColor = UIColor.placeholderBackgroundColor()
        badgeView.layer.cornerRadius = badgeView.height/2
    }

    private func resetUI() {
        avatarImageView.image = nil
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
        badgeView.backgroundColor = UIColor.primaryColor
        badgeLabel.text = ""
        badgeLabel.font = UIFont.conversationBadgeFont
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = UIColor.primaryColor
    }
}
