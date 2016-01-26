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
            thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: UIImage(named: "no_photo"), completed: {
                [weak self] (image, error, cacheType, url) -> Void in
                // tag check to prevent wrong image placement cos' of recycling
                if (error == nil && self?.tag == tag) {
                    self?.thumbnailImageView.image = image
                }
            })
        }
        
        // product name
        productLabel.text = chat.product.name ?? ""
        
        // user name
        userLabel.text = otherUser?.name ?? ""
        
        // time / deleted
        var timeLabelValue: String = ""
        
        if chat.forbidden {
            timeLabelValue = LGLocalizedString.accountDeactivated
            timeLabel.font = StyleHelper.conversationTimeFont
            timeLabel.textColor = StyleHelper.conversationAccountDeactivatedColor
            statusImageView.hidden = true
            separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
        } else {
            switch chat.product.status {
            case .Deleted:
                timeLabelValue = LGLocalizedString.commonProductDeleted
                timeLabel.font = StyleHelper.conversationProductDeletedFont
                timeLabel.textColor = StyleHelper.conversationProductDeletedColor
                statusImageView.image = UIImage(named: "ic_alert_copy")
                statusImageView.hidden = false
                separationStatusImageToTimeLabel.constant = 4
            case .Pending, .Approved, .Discarded:
                if let lastUpdated = chat.updatedAt {
                    timeLabelValue = lastUpdated.relativeTimeString()
                }
                statusImageView.hidden = true
                timeLabel.font = StyleHelper.conversationTimeFont
                timeLabel.textColor = StyleHelper.conversationTimeColor
                
                separationStatusImageToTimeLabel.constant = -statusImageView.frame.width
            case .Sold, .SoldOld:
                timeLabelValue = LGLocalizedString.commonProductSold
                timeLabel.font = StyleHelper.conversationProductSoldFont
                timeLabel.textColor = StyleHelper.conversationProductSoldColor
                statusImageView.image = UIImage(named: "ic_dollar_sold")
                statusImageView.hidden = false
                separationStatusImageToTimeLabel.constant = 4
            }
        }
        
        
        timeLabel.text = timeLabelValue
        
        // badge
        var badge: String? = nil
        if chat.msgUnreadCount > 0 {
            badge = String(chat.msgUnreadCount)
        }

        if let actualBadge = badge {
            badgeView.hidden = false
            badgeLabel.text = actualBadge
        } else {
            badgeView.hidden = true
        }
    }


    // MARK: - Private methods
    
    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.size.width / 2.0
        thumbnailImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
        thumbnailImageView.layer.borderWidth = 1
        productLabel.font = StyleHelper.conversationProductFont
        userLabel.font = StyleHelper.conversationUserNameFont
        timeLabel.font = StyleHelper.conversationTimeFont
        
        productLabel.textColor = StyleHelper.conversationProductColor
        userLabel.textColor = StyleHelper.conversationUserNameColor
        timeLabel.textColor = StyleHelper.conversationTimeColor
        
        badgeView.layer.cornerRadius = 5
    }
    
    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "no_photo")
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
        badgeView.backgroundColor = StyleHelper.badgeBgColor
        badgeLabel.text = ""
    }

    override public func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tintColor = StyleHelper.primaryColor
    }

}
