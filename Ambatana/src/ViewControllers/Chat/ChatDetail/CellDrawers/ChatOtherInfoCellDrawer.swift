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

    override func draw(_ cell: ChatOtherInfoCell, message: ChatViewMessage, bubbleColor: UIColor? = nil) {
        switch message.type {
        case let .userInfo(isDummy, name, address, facebook, google, email):
            cell.set(name: name)
            cell.set(bubbleBackgroundColor: bubbleColor)
            cell.set(userAvatar: message.userAvatarData?.avatarImage, avatarAction: message.userAvatarData?.avatarAction)
            if isDummy {
                cell.setupLetgoAssistantInfo()
            } else {
                cell.setupLocation(address)
                cell.setupVerifiedInfo(facebook: facebook, google: google, email: email)
            }
        default:
            break
        }
    }
}
