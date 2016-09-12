//
//  ChatMyMessageCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatMyMessageCellDrawer: BaseChatCellDrawer<ChatMyMessageCell> {
    
    override func draw(cell: ChatMyMessageCell, message: ChatViewMessage, delegate: AnyObject?) {
        cell.messageLabel.text = message.value ?? ""
        cell.dateLabel.text = message.sentAt?.formattedTime()
        cell.checkImageView.image = nil
        drawCheckForMessage(cell, message: message)
    }

    
    // MARK: - private methods

    private func drawCheckForMessage(cell: ChatMyMessageCell, message: ChatViewMessage) {
        guard let status = message.status else {
            cell.checkImageView.image = nil
            return
        }
        switch status {
        case .Sent:
            cell.checkImageView.image = UIImage(named: "ic_tick_sent")
        case .Received:
            cell.checkImageView.image = UIImage(named: "ic_doble_received")
        case .Read:
            cell.checkImageView.image = UIImage(named: "ic_doble_read")
        case .Unknown:
            cell.checkImageView.image = nil
        }
    }
}
