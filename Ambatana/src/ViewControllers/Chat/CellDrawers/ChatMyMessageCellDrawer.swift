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
    
    override func draw(cell: ChatMyMessageCell, message: Message, avatar: File?, delegate: AnyObject?) {
        cell.messageLabel.text = message.text ?? ""
        cell.dateLabel.text = message.createdAt?.relativeTimeString() ?? ""

        drawCheckForMessage(cell, message: message)
    }


    // MARK: - private methods
    
    private func drawCheckForMessage(cell: ChatMyMessageCell, message: Message) {
        guard let status = message.status else { return }
        switch (status) {
        case .Sent:
            cell.checkImageView.image = UIImage(named: "check_sent")
        case .Read:
            cell.checkImageView.image = UIImage(named: "check_read")
        }
    }
}