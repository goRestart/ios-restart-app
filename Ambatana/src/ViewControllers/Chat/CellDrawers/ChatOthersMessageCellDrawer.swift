//
//  ChatOthersMessageCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatOthersMessageCellDrawer: BaseChatCellDrawer<ChatOthersMessageCell> {
    
    override func draw(cell: ChatOthersMessageCell, message: Message, avatar: File?, delegate: AnyObject?) {
        cell.messageLabel.text = message.text ?? ""
        cell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""
        
        if let delegate = delegate as? ChatOthersMessageCellDelegate {
            cell.delegate = delegate
        }
        
        if let avatar = avatar {
            cell.avatarImageView.sd_setImageWithURL(avatar.fileURL, placeholderImage: UIImage(named: "no_photo"))
        } else {
            cell.avatarImageView.image = UIImage(named: "no_photo")
        }
    }
}
