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
    case listingSold
    case listingGivenAway
    case listingDeleted
    case userPendingDelete
    case userDeleted
    case userBlocked
    case blockedByUser
}

struct ConversationCellData {
    let status: ConversationCellStatus
    let conversationId: String?
    let userId: String?
    let userName: String
    let userImageUrl: URL?
    let userImagePlaceholder: UIImage?
    let listingId: String?
    let listingName: String
    let listingImageUrl: URL?
    let unreadCount: Int
    let messageDate: Date?
}

class ConversationCell: UITableViewCell, ReusableCell {

    static var reusableID = "ConversationCell"

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var listingLabel: UILabel!
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
        if let thumbURL = data.listingImageUrl {
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

        listingLabel.text = data.listingName
        userLabel.text = data.userName

        if data.unreadCount > 0 {
            timeLabel.font = UIFont.conversationTimeUnreadFont
            listingLabel.font = UIFont.conversationProductUnreadFont
            userLabel.font = UIFont.conversationUserNameUnreadFont
        } else {
            timeLabel.font = UIFont.conversationTimeFont
            listingLabel.font = UIFont.conversationProductFont
            userLabel.font = UIFont.conversationUserNameFont
        }

        switch data.status {
        case .forbidden:
            setInfo(text: LGLocalizedString.accountPendingModeration, icon: UIImage(named: "ic_pending_moderation"))
        case .listingSold:
            setInfo(text: LGLocalizedString.commonProductSold, icon: UIImage(named: "ic_dollar_sold"))
        case .listingGivenAway:
            setInfo(text: LGLocalizedString.commonProductGivenAway, icon: UIImage(named: "ic_dollar_sold"))
        case .listingDeleted:
            setInfo(text: LGLocalizedString.commonProductNotAvailable, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .userPendingDelete:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .userDeleted:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_alert_yellow_white_inside"))
            userLabel.text = LGLocalizedString.chatListAccountDeletedUsername
            listingLabel.text = nil
            avatarImageView.image = UIImage(named: "user_placeholder")
        case .available:
            setInfo(text: data.messageDate?.relativeTimeString(false) ?? "", icon: nil)
        case .userBlocked:
            setInfo(text: LGLocalizedString.chatListBlockedUserLabel, icon: UIImage(named: "ic_blocked"))
        case .blockedByUser:
            setInfo(text: LGLocalizedString.chatBlockedByOtherLabel, icon: UIImage(named: "ic_blocked"))
        }

        let badge: String? = data.unreadCount > 0 ? String(data.unreadCount) : nil
        badgeLabel.text = badge
        badgeView.isHidden = (badge == nil)
        
        set(accessibilityId: .conversationCellContainer(conversationId: data.conversationId))
        userLabel.set(accessibilityId: .conversationCellUserLabel(interlocutorId: data.userId))
        listingLabel.set(accessibilityId: .conversationCellListingLabel(listingId: data.listingId))
    }


    // MARK: - Private methods

    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = LGUIKitConstants.smallCornerRadius
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        listingLabel.font = UIFont.conversationProductFont
        userLabel.font = UIFont.conversationUserNameFont
        timeLabel.font = UIFont.conversationTimeFont

        listingLabel.textColor = UIColor.darkGrayText
        userLabel.textColor = UIColor.blackText
        timeLabel.textColor = UIColor.darkGrayText
        thumbnailImageView.backgroundColor = UIColor.placeholderBackgroundColor()
        badgeView.layer.cornerRadius = badgeView.height/2
    }

    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "product_placeholder")
        avatarImageView.image = nil
        listingLabel.text = ""
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
        timeLabel.set(accessibilityId: .conversationCellTimeLabel)
        badgeLabel.set(accessibilityId: .conversationCellBadgeLabel)
        thumbnailImageView.set(accessibilityId: .conversationCellThumbnailImageView)
        avatarImageView.set(accessibilityId: .conversationCellAvatarImageView)
        statusImageView.set(accessibilityId: .conversationCellStatusImageView)
    }
}
