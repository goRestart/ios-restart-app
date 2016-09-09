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
    
    override func draw(cell: ChatOthersMessageCell, message: ChatViewMessage, delegate: AnyObject?) {
        cell.messageLabel.text = message.value ?? ""
        cell.dateLabel.text = message.sentAt?.formattedTime()
    }
}
