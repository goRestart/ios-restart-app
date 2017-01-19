//
//  MockChatUnreadMessages.swift
//  LetGo
//
//  Created by Eli Kohen on 18/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct MockChatUnreadMessages: ChatUnreadMessages {
    let totalUnreadMessages: Int
    init(total: Int) {
        self.totalUnreadMessages = total
    }
}
