//
//  LocalMessage.swift
//  LetGo
//
//  Created by Eli Kohen on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalMessage: Message {
    let objectId: String?
    let text: String
    let type: MessageType
    let userId: String
    let createdAt: NSDate?
    let isRead: Bool
    let warningStatus: MessageWarningStatus

    init(sticker: Sticker) {
        self.objectId = NSDate().description
        self.text = sticker.name
        self.type = .Sticker
        self.userId = ""
        self.createdAt = NSDate()
        self.isRead = false
        self.warningStatus = .Normal
    }
}
