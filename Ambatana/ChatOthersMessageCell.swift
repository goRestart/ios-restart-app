//
//  ChatOthersMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit


class ChatOthersMessageCell: ChatBubbleCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    var avatarButtonPressed: (() -> Void)?
    
    // MARK: > Action
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        avatarButtonPressed?()
    }
    
    
    // MARK: - Private methods

    // Resets the UI to the initial state
    internal override func resetUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        avatarImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
        avatarImageView.layer.borderWidth = 1
    }
}
