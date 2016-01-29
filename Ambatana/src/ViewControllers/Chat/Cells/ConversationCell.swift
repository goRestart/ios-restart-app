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

    
    // MARK: - Overrides
    
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected && !editing) {
            setSelected(false, animated: animated)
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
        
        if let avatarURL = otherUser?.avatar?.fileURL {
            avatarImageView.sd_setImageWithURL(avatarURL, placeholderImage: UIImage(named: "no_photo")) {
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
            timeLabel.font = StyleHelper.conversationTimeFont
            timeLabel.textColor = StyleHelper.conversationAccountDeactivatedColor
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        case .Sold:
            timeLabel.text = LGLocalizedString.commonProductSold
            timeLabel.font = StyleHelper.conversationProductSoldFont
            timeLabel.textColor = StyleHelper.conversationProductSoldColor
            statusImageView.image = UIImage(named: "ic_dollar_sold")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = 4
        case .Deleted:
            timeLabel.text = LGLocalizedString.commonProductDeleted
            timeLabel.font = StyleHelper.conversationProductDeletedFont
            timeLabel.textColor = StyleHelper.conversationProductDeletedColor
            statusImageView.image = UIImage(named: "ic_alert")
            statusImageView.hidden = false
            separationStatusImageToTimeLabel.constant = 4
        case .Available:
            timeLabel.text = chat.updatedAt?.relativeTimeString() ?? ""
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width

            timeLabel.font = StyleHelper.conversationTimeFont
            timeLabel.textColor = StyleHelper.conversationTimeColor
        }
        
        let badge: String? = chat.msgUnreadCount > 0 ? String(chat.msgUnreadCount) : nil
        badgeLabel.text = badge
        badgeView.hidden = (badge == nil)
    }


    // MARK: - Private methods
    
    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = 4
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
        productLabel.font = SqtyleHelper.conversationProductFont
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
        super.setEditing(editing, animated: animated)
        tintColor = StyleHelper.primaryColor
    }

}
