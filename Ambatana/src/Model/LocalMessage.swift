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
    let createdAt: Date?
    let isRead: Bool
    let warningStatus: MessageWarningStatus

    init(sticker: Sticker, userId: String?) {
        self.objectId = NSDate().description
        self.text = sticker.name
        self.type = .sticker
        self.userId = userId ?? ""
        self.createdAt = Date()
        self.isRead = false
        self.warningStatus = .normal
    }

    init(text: String, userId: String?) {
        self.objectId = Date().description
        self.text = text
        self.type = .text
        self.userId = userId ?? ""
        self.createdAt = Date()
        self.isRead = false
        self.warningStatus = .normal
    }

    init(type: ChatWrapperMessageType, userId: String?) {
        self.objectId = Date().description
        self.text = type.text
        self.type = type.oldChatType
        self.userId = userId ?? ""
        self.createdAt = Date()
        self.isRead = false
        self.warningStatus = .normal
    }
}
