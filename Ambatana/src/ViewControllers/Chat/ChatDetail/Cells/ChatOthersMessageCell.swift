//
//  ChatOthersMessageCell.swift
//  LetGo
//
//  Created by Albert Hernández López on 19/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

class ChatOthersMessageCell: ChatBubbleCell, ReusableCell {
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        bubbleView.backgroundColor = selected ? UIColor.chatOthersBubbleBgColorSelected : UIColor.chatOthersBubbleBgColor
    }
}
