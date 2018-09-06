//
//  ChatCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ChatCellDrawerFactory {
    
    static func drawerForMessage(_ message: ChatViewMessage,
                                 autoHide: Bool = false,
                                 disclosure: Bool = false,
                                 meetingsEnabled: Bool) -> ChatCellDrawer {
        let myUserRepository = Core.myUserRepository
        
        let isMine = message.talkerId == myUserRepository.myUser?.objectId
        switch message.type {
        case .offer, .text, .multiAnswer, .unsupported:
            if isMine {
                return ChatMyMessageCellDrawer(showDisclose: disclosure, autoHide: autoHide)
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
                    return ChatMyMessageCellDrawer(showDisclose: disclosure, autoHide: autoHide)
                } else {
                    return ChatOthersMessageCellDrawer(autoHide: autoHide)
                }
            }
        case .cta:
            return ChatCallToActionCellDrawer(autoHide: autoHide)
        case .carousel:
            return ChatCarouselDrawer(autoHide: autoHide)
        case .interlocutorIsTyping:
            return ChatInterlocutorIsTypingCellDrawer(autoHide: autoHide)
        }
    }
    
    static func registerCells(_ tableView: UITableView) {
        ChatMyMessageCellDrawer.registerClassCell(tableView)
        ChatOthersMessageCellDrawer.registerClassCell(tableView)
        ChatStickerCellDrawer.registerClassCell(tableView)
        ChatDisclaimerCellDrawer.registerClassCell(tableView)
        ChatOtherInfoCellDrawer.registerClassCell(tableView)
        ChatAskPhoneNumberCellDrawer.registerClassCell(tableView)
        ChatInterlocutorIsTypingCellDrawer.registerClassCell(tableView)
        ChatCallToActionCellDrawer.registerClassCell(tableView)
        ChatCarouselDrawer.registerClassCell(tableView)
        ChatOtherMeetingCellDrawer.registerCell(tableView)
        ChatMyMeetingCellDrawer.registerCell(tableView)
    }
}
