//
//  ChatOthersMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ChatOthersMessageCell: UITableViewCell {

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var avatarButtonPressed: (() -> Void)?
    
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
    
    // MARK: - Public methods
    
    // MARK: > Action
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        avatarButtonPressed?()
    }
    
    // MARK: - Private methods
    
    // Sets up the UI
    private func setupUI() {
        bubbleView.layer.cornerRadius = 4
//        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
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
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
//        thumbnailImageView.image = UIImage(named: "no_photo")
//        productLabel.text = ""
//        userLabel.text = ""
//        timeLabel.text = ""
//        badgeView.hidden = true
//        badgeLabel.text = ""
    }
}
