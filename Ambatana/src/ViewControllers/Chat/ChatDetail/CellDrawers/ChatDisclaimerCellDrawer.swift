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

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }
    
    override func draw(_ cell: ChatDisclaimerCell, message: ChatViewMessage) {
        switch message.type {
        case let .disclaimer(showAvatar, text, actionTitle, action):
            cell.showAvatar(showAvatar)
            cell.setMessage(text)
            cell.setButton(title: actionTitle)
            cell.setButton(action: action)
        default:
            break
        }
    }
}
