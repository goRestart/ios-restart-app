//
//  ChatOtherInfoCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 15/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class ChatOtherInfoCellDrawer: BaseChatCellDrawer<ChatOtherInfoCell> {
    override func draw(cell: ChatOtherInfoCell, message: ChatViewMessage, delegate: AnyObject?) {
        switch message.type {
        case let .UserInfo(name, address, facebook, google, email):
            cell.nameLabel.text = name
            cell.locationLabel.text = address
            cell.setupVerifiedInfo(facebook: facebook, google: google, email: email)
        default:
            break
        }
    }
}
