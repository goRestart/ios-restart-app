//
//  ChatMyMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ChatMyMessageCell: ChatBubbleCell, ReusableCell {

    static let reusableID = "ChatMyMessageCell"

    @IBOutlet weak var checkImageView: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? StyleHelper.chatMyBubbleBgColorSelected : StyleHelper.chatMyBubbleBgColor
    }
}
