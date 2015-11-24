//
//  ChatOthersMessageCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public class ChatOthersMessageCellDrawer: ChatCellDrawer {
    public func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(ChatOthersMessageCell.cellID(), forIndexPath: atIndexPath)
    }
    
    public func draw(cell: UITableViewCell, message: Message, avatar: File?) {
        guard let othersCell = cell as? ChatOthersMessageCell else { return }
        othersCell.messageLabel.text = message.text ?? ""
        othersCell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""
        
        if let avatar = avatar {
            othersCell.avatarImageView.sd_setImageWithURL(avatar.fileURL, placeholderImage: UIImage(named: "no_photo"))
        }
        else {
            othersCell.avatarImageView.image = UIImage(named: "no_photo")
        }
    }
}
