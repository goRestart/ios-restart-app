//
//  ChatAskPhoneNumberCellDrawer.swift
//  LetGo
//
//  Created by Dídac on 23/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatAskPhoneNumberCellDrawer: BaseChatCellDrawer<ChatAskPhoneNumberCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatAskPhoneNumberCell, message: ChatViewMessage) {
        cell.messageLabel.text = message.value
        cell.dateLabel.text = message.sentAt?.formattedTime()
        switch message.type {
        case let .askPhoneNumber(_, action):
            cell.buttonAction = action
            cell.leavePhoneNumberButton.isEnabled = action != nil
            cell.leavePhoneNumberButton.setStyle(.secondary(fontSize: .small, withBorder: true))
            cell.leavePhoneNumberButton.setTitle("_ Leave phone number", for: .normal)
        default:
            break
        }
    }
}
