//
//  ChatOtherInfoCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 15/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


class ChatOtherInfoCellDrawer: BaseChatCellDrawer<ChatOtherInfoCell> {

    override init(autoHide: Bool) {
        super.init(autoHide: autoHide)
    }

    override func draw(_ cell: ChatOtherInfoCell, message: ChatViewMessage) {
        switch message.type {
        case let .userInfo(name, address, facebook, google, email):
            cell.nameLabel.text = name
            cell.setupLocation(address)
            cell.setupVerifiedInfo(facebook: facebook, google: google, email: email)
        default:
            break
        }
    }
}