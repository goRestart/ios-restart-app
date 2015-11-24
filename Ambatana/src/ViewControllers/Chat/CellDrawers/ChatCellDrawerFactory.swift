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
    public static func drawerForMessage(message: Message) -> ChatCellDrawer {
        return message.isFromLoggedUser() ? ChatMyMessageCellDrawer() : ChatOthersMessageCellDrawer()
    }
}
