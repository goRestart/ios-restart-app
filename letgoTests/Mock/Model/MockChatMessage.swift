//
//  MockChatMessage.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct MockChatMessage: ChatMessage {
    var objectId: String?
    var talkerId: String
    var text: String
    var sentAt: Date?
    var receivedAt: Date?
    var readAt: Date?
    var type: ChatMessageType
    var warnings: [ChatMessageWarning]

    init() {
        self.objectId = String.random(20)
        self.talkerId = String.random(20)
        self.text = String.random(10)
        self.sentAt = Date()
        self.receivedAt = nil
        self.readAt = nil
        self.type = .text
        self.warnings = []
    }

    func markReceived() -> ChatMessage {
        var result = self
        result.receivedAt = Date()
        return result
    }
}
