//
//  ConversationCell.swift
//  LetGo
//
//  Created by AHL on 25/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import SDWebImage
import UIKit

public class ConversationCell: UITableViewCell {

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

    var lines: [CALayer] = []


    // MARK: - Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
        self.resetUI()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        self.resetUI()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        // Redraw the lines
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines = []
        lines.append(contentView.addBottomBorderWithWidth(1, color: StyleHelper.lineColor))
    }


    // MARK: - Overrides

    public override func setSelected(selected: Bool, animated: Bool) {
        if (selected && !editing) {
            super.setSelected(false, animated: animated)
        } else {
            super.setSelected(selected, animated: animated)
        }
    }


    // MARK: - Public methods

    public func setupCellWithChat(chat: Chat, myUser: User, indexPath: NSIndexPath) {
        let tag = indexPath.hash

        var otherUser: User?
        if let myUserId = myUser.objectId, let userFromId = chat.userFrom.objectId, let _ = chat.userTo.objectId {
            otherUser = (myUserId == userFromId) ? chat.userTo : chat.userFrom
        }

        // thumbnail
        if let thumbURL = chat.product.thumbnail?.fileURL {
            thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: UIImage(named: "no_photo")) {
                [weak self] (image, error, cacheType, url) in
                // tag check to prevent wrong image placement cos' of recycling
                if (error == nil && self?.tag == tag) {
                    self?.thumbnailImageView.image = image
                }
            }
        }
        
        let placeholder = LetgoAvatar.avatarWithID(otherUser?.objectId, name: otherUser?.name)
        avatarImageView.image = placeholder

        if let avatarURL = otherUser?.avatar?.fileURL {
            avatarImageView.sd_setImageWithURL(avatarURL, placeholderImage: placeholder) {
                [weak self] (image, error, cacheType, url)  in
                if error == nil && self?.tag == tag {
                    self?.avatarImageView.image = image
                }
            }
        }

        productLabel.text = chat.product.name ?? ""
        userLabel.text = otherUser?.name ?? ""

        if chat.msgUnreadCount > 0 {
            timeLabel.font = StyleHelper.conversationTimeUnreadFont
            productLabel.font = StyleHelper.conversationProductUnreadFont
            userLabel.font = StyleHelper.conversationUserNameUnreadFont
        } else {
            timeLabel.font = StyleHelper.conversationTimeFont
            productLabel.font = StyleHelper.conversationProductFont
            userLabel.font = StyleHelper.conversationUserNameFont
        }

        switch chat.status {
        case .Forbidden:
            timeLabel.text = LGLocalizedString.accountDeactivated
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        case .Sold:
            timeLabel.text = LGLocalizedString.commonProductSold
            statusImageView.image = UIImage(named: "ic_dollar_sold")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = StyleHelper.defaultCornerRadius
        case .Deleted:
            timeLabel.text = LGLocalizedString.commonProductNotAvailable
            statusImageView.image = UIImage(named: "ic_alert_black")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = StyleHelper.defaultCornerRadius
        case .Available:
            timeLabel.text = chat.updatedAt?.relativeTimeString() ?? ""
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        }

        let badge: String? = chat.msgUnreadCount > 0 ? String(chat.msgUnreadCount) : nil
        badgeLabel.text = badge
        badgeView.hidden = (badge == nil)
    }


    // MARK: - Private methods

    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.whiteColor()
        productLabel.font = StyleHelper.conversationProductFont
        userLabel.font = StyleHelper.conversationUserNameFont
        timeLabel.font = StyleHelper.conversationTimeFont

        productLabel.textColor = StyleHelper.conversationProductColor
        userLabel.textColor = StyleHelper.conversationUserNameColor
        timeLabel.textColor = StyleHelper.conversationTimeColor

        badgeView.layer.cornerRadius = badgeView.height/2
    }

    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "no_photo")
        avatarImageView.image = UIImage(named: "no_photo")
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
        badgeView.backgroundColor = StyleHelper.badgeBgColor
        badgeLabel.text = ""
        badgeLabel.font = StyleHelper.conversationBadgeFont
    }

    override public func setEditing(editing: Bool, animated: Bool) {
        if (editing) {
            let bgView = UIView()
            selectedBackgroundView = bgView
        } else {
            selectedBackgroundView = nil
        }
        super.setEditing(editing, animated: animated)
        tintColor = StyleHelper.primaryColor
    }
}
