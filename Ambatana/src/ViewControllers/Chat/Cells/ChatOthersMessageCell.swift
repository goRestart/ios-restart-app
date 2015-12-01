//
//  ChatOthersMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

protocol ChatOthersMessageCellDelegate {
    func didTapOnUserAvatar()
}

class ChatOthersMessageCell: ChatBubbleCell, ReusableCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    var avatarButtonPressed: (() -> Void)?
    var delegate: ChatOthersMessageCellDelegate?
    
    static func reusableID() -> String {
        return "ChatOthersMessageCell"
    }
    
    
    // MARK: > Action
    
    @IBAction func avatarButtonPressed(sender: AnyObject) {
        delegate?.didTapOnUserAvatar()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? StyleHelper.chatOthersBubbleBgColorSelected : StyleHelper.chatOthersBubbleBgColor
    }
    
    
    // MARK: > Private methods
    // Resets the UI to the initial state
    internal override func resetUI() {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
        avatarImageView.layer.borderColor = StyleHelper.chatCellAvatarBorderColor.CGColor
        avatarImageView.layer.borderWidth = 1
    }
}
