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
    
    static func drawerForMessage(message: Message) -> ChatCellDrawer {
        return MyUserManager.sharedInstance.isMessageMine(message) ? ChatMyMessageCellDrawer() : ChatOthersMessageCellDrawer()
    }
    
    static func registerCells(tableView: UITableView) {
        ChatMyMessageCellDrawer.registerCell(tableView)
        ChatOthersMessageCellDrawer.registerCell(tableView)
    }
}