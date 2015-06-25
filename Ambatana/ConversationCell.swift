//
//  ConversationCell.swift
//  LetGo
//
//  Created by AHL on 25/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

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
       
    public func setupCellWithConversation(conversation: LetGoConversation, indexPath: NSIndexPath) {
        let tag = indexPath.hash
    
        // thumbnail
        if let thumbURL = NSURL(string: conversation.userAvatarURL) {
            thumbnailImageView.sd_setImageWithURL(thumbURL, placeholderImage: UIImage(named: "no_photo"), completed: {
                [weak self] (image, error, cacheType, url) -> Void in
                // tag check to prevent wrong image placement cos' of recycling
                if (error == nil && self?.tag == tag) {
                    self?.thumbnailImageView.image = image
                }
            })
        }
        
        // product name
        productLabel.text = conversation.productName
        
        // user name
        userLabel.text = conversation.userName
        
        // time
        timeLabel.text = conversation.lastUpdated.relativeTimeString()
        
        // badge
        if conversation.myUnreadMessages > 0 {
            badgeView.hidden = false
            badgeLabel.text = String(conversation.myUnreadMessages)
        }
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.size.width / 2.0
        productLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        userLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        badgeView.layer.cornerRadius = 5//thumbnailImageView.frame.size.height / 2.0
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
