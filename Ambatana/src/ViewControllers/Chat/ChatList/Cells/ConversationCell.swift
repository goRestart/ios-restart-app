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
    case ProductSold
    case ProductDeleted
    case UserPendingDelete
    case UserDeleted
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
        lines.append(contentView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }


    // MARK: - Overrides

    override func setSelected(selected: Bool, animated: Bool) {
        if (selected && !editing) {
            super.setSelected(false, animated: animated)
        } else {
            super.setSelected(selected, animated: animated)
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = StyleHelper.primaryColor
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
            timeLabel.font = StyleHelper.conversationTimeUnreadFont
            productLabel.font = StyleHelper.conversationProductUnreadFont
            userLabel.font = StyleHelper.conversationUserNameUnreadFont
        } else {
            timeLabel.font = StyleHelper.conversationTimeFont
            productLabel.font = StyleHelper.conversationProductFont
            userLabel.font = StyleHelper.conversationUserNameFont
        }

        switch data.status {
        case .Forbidden:
            setInfo(text: LGLocalizedString.accountDeactivated, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .ProductSold:
            setInfo(text: LGLocalizedString.commonProductSold, icon: UIImage(named: "ic_dollar_sold"))
        case .ProductDeleted:
            setInfo(text: LGLocalizedString.commonProductNotAvailable, icon: UIImage(named: "ic_alert_yellow_white_inside"))
        case .UserPendingDelete:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_blocked"))
        case .UserDeleted:
            setInfo(text: LGLocalizedString.chatListAccountDeleted, icon: UIImage(named: "ic_blocked"))
            userLabel.text = LGLocalizedString.chatListAccountDeletedUsername
            productLabel.text = nil
            avatarImageView.image = UIImage(named: "user_placeholder")
        case .Available:
            setInfo(text: data.messageDate?.relativeTimeString(false) ?? "", icon: nil)
        }

        let badge: String? = data.unreadCount > 0 ? String(data.unreadCount) : nil
        badgeLabel.text = badge
        badgeView.hidden = (badge == nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        productLabel.font = StyleHelper.conversationProductFont
        userLabel.font = StyleHelper.conversationUserNameFont
        timeLabel.font = StyleHelper.conversationTimeFont

        productLabel.textColor = StyleHelper.conversationProductColor
        userLabel.textColor = StyleHelper.conversationUserNameColor
        timeLabel.textColor = StyleHelper.conversationTimeColor
        thumbnailImageView.backgroundColor = StyleHelper.conversationCellBgColor
        badgeView.layer.cornerRadius = badgeView.height/2
    }

    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "product_placeholder")
        avatarImageView.image = nil
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
        badgeView.backgroundColor = StyleHelper.badgeBgColor
        badgeLabel.text = ""
        badgeLabel.font = StyleHelper.conversationBadgeFont
    }

    private func setInfo(text text: String?, icon: UIImage?) {
        timeLabel.text = text
        if let icon = icon {
            statusImageView.image = icon
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = ConversationCell.statusImageDefaultMargin
        } else {
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        }
    }
}
