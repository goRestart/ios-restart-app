//
//  MockChat.swift
//  LetGo
//
//  Created by Dídac on 22/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class MockChat: MockBaseModel, Chat {

    // Chat iVars
    var product: Product
    var userFrom: User
    var userTo: User
    var msgUnreadCount: Int
    var messages: [Message]
    var forbidden: Bool
    var archivedStatus: ChatArchivedStatus

    // Lifecycle

    override init() {

        self.product = MockProduct()
        self.userFrom = MockUser()
        self.userTo = MockUser()
        self.msgUnreadCount = 1

        let messageOne = LGMessage()
        let messageTwo = LGMessage()
        self.messages = [messageOne, messageTwo]
        self.forbidden = false
        self.archivedStatus = .active
        super.init()
    }

    func prependMessage(message: Message) {
        self.messages.insert(message, atIndex: 0)
    }
}
