//
//  ChatDisclaimerCellDrawer.swift
//  LetGo
//
//  Created by Isaac Roldan on 31/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatDisclaimerCellDrawer: BaseChatCellDrawer<ChatDisclaimerCell> {
    
    override func draw(cell: ChatDisclaimerCell, message: ChatViewMessage, delegate: AnyObject?) {
        switch message.type {
        case let .Disclaimer(showAvatar, text, actionTitle, action):
            cell.showAvatar(showAvatar)
            cell.setMessage(text)
            cell.setButton(title: actionTitle)
            cell.setButton(action: action)
        default:
            break
        }
    }
}
