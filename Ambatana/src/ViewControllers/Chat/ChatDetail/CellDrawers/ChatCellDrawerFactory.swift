//
//  ChatCellDrawerFactory.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public class ChatCellDrawerFactory {
    
    static func drawerForMessage(message: ChatViewMessage) -> ChatCellDrawer {
        let myUserRepository = Core.myUserRepository
        
        let isMine = message.talkerId == myUserRepository.myUser?.objectId
        switch message.type {
        case .Offer, .Text:
            return isMine ? ChatMyMessageCellDrawer() : ChatOthersMessageCellDrawer()
        case .Sticker:
            return ChatStickerCellDrawer(messageIsMine: isMine)
        }
    }
    
    static func registerCells(tableView: UITableView) {
        ChatMyMessageCellDrawer.registerCell(tableView)
        ChatOthersMessageCellDrawer.registerCell(tableView)
        ChatStickerCellDrawer.registerCell(tableView)
    }
}
