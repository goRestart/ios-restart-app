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

    var showDisclose: Bool = false
    var showClock: Bool = false
    
    private let rightMarginMessageTextDefault: CGFloat = 10
    private let rightMarginWithDisclosure: CGFloat = 38
    
    init(showDisclose: Bool, autoHide: Bool, showClock: Bool) {
        self.showDisclose = showDisclose
        self.showClock = showClock
        super.init(autoHide: autoHide)
    }
    
    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatMyMessageCell, message: ChatViewMessage) {
        cell.set(text: message.value)
        cell.dateLabel.text = message.sentAt?.formattedTime()
        cell.checkImageView.image = nil
        drawCheckForMessage(cell, message: message)
        drawDisclosureForMessage(cell, disclosure: showDisclose)
    }

    
    // MARK: - private methods

    private func drawCheckForMessage(_ cell: ChatMyMessageCell, message: ChatViewMessage) {
        guard let status = message.status else {
            cell.checkImageView.image = nil
            return
        }
        switch status {
        case .sent:
            cell.checkImageView.image = UIImage(named: "ic_tick_sent")
        case .received:
            cell.checkImageView.image = UIImage(named: "ic_doble_received")
        case .read:
            cell.checkImageView.image = UIImage(named: "ic_doble_read")
        case .unknown:
            cell.checkImageView.image = showClock ? UIImage(named: "ic_watch") : nil
        }
    }
    
    private func drawDisclosureForMessage(_ cell: ChatMyMessageCell, disclosure: Bool) {
        if disclosure {
            cell.disclosureImageView.image = UIImage(named: "ic_disclosure_chat")
            cell.marginRightConstraints.forEach { $0.constant = rightMarginWithDisclosure }
        } else {
            cell.disclosureImageView.image = nil
            cell.marginRightConstraints.forEach { $0.constant = rightMarginMessageTextDefault }
        }
        
    }
}
