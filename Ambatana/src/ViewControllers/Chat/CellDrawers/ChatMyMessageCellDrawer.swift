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
    
    override func draw(cell: ChatMyMessageCell, message: Message, delegate: AnyObject?) {
        cell.messageLabel.text = message.text ?? ""
        cell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""
        cell.checkImageView.image = UIImage(named: "ic_check_sent")
        drawCheckForMessage(cell, message: message)
    }

    override func draw(cell: ChatMyMessageCell, message: ChatMessage, delegate: AnyObject?) {
        cell.messageLabel.text = message.text ?? ""
        cell.dateLabel.text = message.sentAt?.relativeTimeString() ?? LGLocalizedString.productChatMessageSending
        cell.checkImageView.image = nil
        drawCheckForMessage(cell, message: message)
    }

    // MARK: - private methods
    
    private func drawCheckForMessage(cell: ChatMyMessageCell, message: Message) {
        guard let status = message.status else { return }
        switch (status) {
        case .Sent:
            cell.checkImageView.image = UIImage(named: "ic_check_sent")
        case .Read:
            cell.checkImageView.image = UIImage(named: "ic_check_read")
        }
    }
    
    private func drawCheckForMessage(cell: ChatMyMessageCell, message: ChatMessage) {
        switch message.messageStatus {
        case .Sent, .Received:
            cell.checkImageView.image = UIImage(named: "ic_check_sent")
        case .Read:
            cell.checkImageView.image = UIImage(named: "ic_check_read")
        case .Unknown:
            cell.checkImageView.image = nil
        }
    }
}