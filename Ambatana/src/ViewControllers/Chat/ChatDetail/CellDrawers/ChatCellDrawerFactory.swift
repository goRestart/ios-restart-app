//
//  ChatCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class ChatCellDrawerFactory {
    
    static func drawerForMessage(_ message: ChatViewMessage,
                                 autoHide: Bool = false,
                                 disclosure: Bool = false,
                                 showClock: Bool = false,
                                 meetingsEnabled: Bool) -> ChatCellDrawer {
        let myUserRepository = Core.myUserRepository
        
        let isMine = message.talkerId == myUserRepository.myUser?.objectId
        switch message.type {
        case .offer, .text, .multiAnswer, .unsupported:
            if isMine {
                return ChatMyMessageCellDrawer(showDisclose: disclosure, autoHide: autoHide, showClock: showClock)
            } else {
                return ChatOthersMessageCellDrawer(autoHide: autoHide)
            }
        case .sticker:
            return ChatStickerCellDrawer(messageIsMine: isMine, autoHide: autoHide)
        case .disclaimer:
            return ChatDisclaimerCellDrawer(autoHide: autoHide)
        case .userInfo:
            return ChatOtherInfoCellDrawer(autoHide: autoHide)
        case .askPhoneNumber:
            return ChatAskPhoneNumberCellDrawer(autoHide: autoHide)
        case let .meeting(type,_,_,_,_,_):
            if meetingsEnabled, type == .requested {
                if isMine {
                    return ChatMyMeetingCellDrawer(autoHide: autoHide)
                } else {
                    return ChatOtherMeetingCellDrawer(autoHide: autoHide)
                }
            } else {
                if isMine {
                    return ChatMyMessageCellDrawer(showDisclose: disclosure, autoHide: autoHide, showClock: showClock)
                } else {
                    return ChatOthersMessageCellDrawer(autoHide: autoHide)
                }
            }
        case .interlocutorIsTyping:
            return ChatInterlocutorIsTypingCellDrawer(autoHide: autoHide)
        }
    }
    
    static func registerCells(_ tableView: UITableView) {
        ChatMyMessageCellDrawer.registerCell(tableView)
        ChatOthersMessageCellDrawer.registerCell(tableView)
        ChatStickerCellDrawer.registerCell(tableView)
        ChatDisclaimerCellDrawer.registerCell(tableView)
        ChatOtherInfoCellDrawer.registerCell(tableView)
        ChatAskPhoneNumberCellDrawer.registerCell(tableView)
        ChatInterlocutorIsTypingCellDrawer.registerCell(tableView)

        ChatOtherMeetingCellDrawer.registerCell(tableView)
        ChatMyMeetingCellDrawer.registerCell(tableView)
    }
}
