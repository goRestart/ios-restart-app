//
//  ChatMyMessageCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public class ChatMyMessageCellDrawer: ChatCellDrawer {
    public func cell(tableView: UITableView, atIndexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(ChatMyMessageCell.cellID(), forIndexPath: atIndexPath)
    }
    
    public func draw(cell: UITableViewCell, message: Message, avatar: File?, delegate: AnyObject?) {
        guard let myCell = cell as? ChatMyMessageCell else { return }
        myCell.messageLabel.text = message.text ?? ""
        myCell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""
    }
}