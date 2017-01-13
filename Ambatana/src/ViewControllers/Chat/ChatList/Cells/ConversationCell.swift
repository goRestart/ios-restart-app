//
//  ConversationCell.swift
//  LetGo
//
//  Created by AHL on 25/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

enum ConversationCellStatus {
    case available
    case forbidden
    case productSold
    case productDeleted
    case userPendingDelete
    case userDeleted
}

struct ConversationCellData {
    let status: ConversationCellStatus
    let userName: String
    let userImageUrl: URL?
    let userImagePlaceholder: UIImage?
    let productName: String
    let productImageUrl: URL?
    let unreadCount: Int
    let messageDate: Date?
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
        setupUI()
        resetUI()
        setAccessibilityIds()
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        if (selected && !isEditing) {
            super.setSelected(false, animated: animated)
        } else {
            super.setSelected(selected, animated: animated)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = UIColor.primaryColor
    }


    // MARK: - Public methods

    func setupCellWithData(_ data: ConversationCellData, indexPath: IndexPath) {
        let tag = (indexPath as NSIndexPath).hash

        // thumbnail
        if let thumbURL = data.productImageUrl {
            thumbnailImageView.lg_setImageWithURL(thumbURL) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
                    self?.thumbnailImageView.image = image
                }
            }
        }
        avatarImageView.image = data.userImagePlaceholder
        if let avatarURL = data.userImageUrl {
            avatarImageView.lg_setImageWithURL(avatarURL, placeholderImage: data.userImagePlaceholder) {
                [weak self] (result, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if let image = result.value?.image, self?.tag == tag {
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
        case .forbidden:
            setInfo(text: LGLocalizedString.accountPendingModeration, icon: UIImage(named: "ic_pending_moderation"))
        case .productSold:
            setInfo(text: LGLocalizedString.commonProductSold, icon: UIImage(named: "ic_dollar_sold"))
        case .productDeleted:
            setInfo(text: LGLocalizedString.commonProductNotAvailable, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .userPendingDelete:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .userDeleted:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_alert_yellow_white_inside"))
            userLabel.text = LGLocalizedString.chatListAccountDeletedUsername
            productLabel.text = nil
            avatarImageView.image = UIImage(named: "user_placeholder")
        case .available:
            setInfo(text: data.messageDate?.relativeTimeString(false) ?? "", icon: nil)
        }

        let badge: String? = data.unreadCount > 0 ? String(data.unreadCount) : nil
        badgeLabel.text = badge
        badgeView.isHidden = (badge == nil)
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
        thumbnailImageView.image = UIImage(named: "product_placeholder")
        avatarImageView.image = nil
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.isHidden = true
        badgeView.backgroundColor = UIColor.primaryColor
        badgeLabel.text = ""
        badgeLabel.font = UIFont.conversationBadgeFont
    }

    private func setInfo(text: String?, icon: UIImage?) {
        timeLabel.text = text
        if let icon = icon {
            statusImageView.image = icon
            statusImageView.isHidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        } else {
            statusImageView.isHidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        }
    }
}

extension ConversationCell {
    func setAccessibilityIds() {
        contentView.accessibilityId = AccessibilityId.conversationCellContainer
        userLabel.accessibilityId = AccessibilityId.conversationCellUserLabel
        timeLabel.accessibilityId = AccessibilityId.conversationCellTimeLabel
        productLabel.accessibilityId = AccessibilityId.conversationCellProductLabel
        badgeLabel.accessibilityId = AccessibilityId.conversationCellBadgeLabel
        thumbnailImageView.accessibilityId = AccessibilityId.conversationCellThumbnailImageView
        avatarImageView.accessibilityId = AccessibilityId.conversationCellAvatarImageView
        statusImageView.accessibilityId = AccessibilityId.conversationCellStatusImageView
    }
}
