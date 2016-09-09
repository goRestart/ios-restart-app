//
//  ChatUnreadMessages.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol ChatUnreadMessages {
    var totalUnreadMessages: Int { get }
    var unreadConversations: [ConversationUnreadMessages] { get }
}

public protocol ConversationUnreadMessages {
    var conversationId: String { get }
    var unreadMessages: Int { get }
}
