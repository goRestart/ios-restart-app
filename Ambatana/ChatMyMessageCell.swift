//
//  ChatMyMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ChatMyMessageCell: UITableViewCell, ChatBubbleCell {

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        bubbleView.layer.cornerRadius = 4
        messageLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        dateLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
//        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.size.width / 2.0
//        productLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
//        userLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
//        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
//        badgeView.layer.cornerRadius = 5//thumbnailImageView.frame.size.height / 2.0
    }
    
    // Resets the UI to the initial state
    private func resetUI() {
//        thumbnailImageView.image = UIImage(named: "no_photo")
//        productLabel.text = ""
//        userLabel.text = ""
//        timeLabel.text = ""
//        badgeView.hidden = true
//        badgeLabel.text = ""
    }
    
}
