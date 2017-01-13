//
//  ChatStickerCell.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation


class ChatStickerCell: UITableViewCell, ReusableCell {
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAccessibilityIds()
        backgroundColor = UIColor.clear
    }
}

extension ChatStickerCell {
    func setAccessibilityIds() {
        leftImage.accessibilityId = .chatStickerCellLeftImage
        rightImage.accessibilityId = .chatStickerCellRightImage
    }
}
