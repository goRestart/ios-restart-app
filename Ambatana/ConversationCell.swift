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
        if (selected) {
            setSelected(false, animated: animated)
        }
    }
    
    // MARK: - Public methods
       
    public func setupCellWithChat(chat: Chat, myUser: User, indexPath: NSIndexPath) {
        let tag = indexPath.hash
    
        var otherUser: User?
        if let myUserId = myUser.objectId, let userFrom = chat.userFrom, let userFromId = userFrom.objectId, let userTo = chat.userTo, let userToId = userTo.objectId {
                otherUser = (myUserId == userFromId) ? userTo : userFrom
        }
        
        // thumbnail
        if let thumbURL = otherUser?.avatar?.fileURL {
            thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: UIImage(named: "no_photo"), completed: {
                [weak self] (image, error, cacheType, url) -> Void in
                // tag check to prevent wrong image placement cos' of recycling
                if (error == nil && self?.tag == tag) {
                    self?.thumbnailImageView.image = image
                }
            })
        }
        
        // product name
        productLabel.text = chat.product?.name ?? ""
        
        // user name
        userLabel.text = otherUser?.publicUsername ?? ""
        
        // time / deleted
        var timeLabelValue: String = ""
        if let productStatus = chat.product?.status {
            switch productStatus {
            case .Deleted:
                timeLabelValue = LGLocalizedString.commonProductDeleted
            case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
                if let lastUpdated = chat.updatedAt {
                    timeLabelValue = lastUpdated.relativeTimeString()
                }
            }
        }
        timeLabel.text = timeLabelValue
        
        // badge
        var badge: String? = nil
        if let msgUnreadCount = chat.msgUnreadCount {
            if msgUnreadCount.integerValue > 0 {
                badge = msgUnreadCount.stringValue
            }
        }

        if let actualBadge = badge {
            badgeView.hidden = false
            badgeLabel.text = actualBadge
        }
        else {
            badgeView.hidden = true
        }
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.size.width / 2.0
        thumbnailImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
        thumbnailImageView.layer.borderWidth = 1
        productLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        userLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        badgeView.layer.cornerRadius = 5
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
        thumbnailImageView.image = UIImage(named: "no_photo")
        productLabel.text = ""
        userLabel.text = ""
        timeLabel.text = ""
        badgeView.hidden = true
        badgeView.backgroundColor = StyleHelper.badgeBgColor
        badgeLabel.text = ""
    }
    
}
