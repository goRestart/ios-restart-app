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
    
    override func draw(cell: ChatOthersMessageCell, message: Message, delegate: AnyObject?) {
        cell.messageLabel.text = message.text ?? ""
        cell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""
    }
}
