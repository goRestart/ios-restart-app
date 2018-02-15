//
//  LGChatUnreadMessages.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 08/09/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatUnreadMessages {
    var totalUnreadMessages: Int { get }
}

struct LGChatUnreadMessages: ChatUnreadMessages, Decodable {
    let totalUnreadMessages: Int
    
    // MARK: Decodable
    
    /*
     {
     "total_unread_messages_count": 2
     }
     */
    
    enum CodingKeys: String, CodingKey {
        case totalUnreadMessages = "total_unread_messages_count"
    }
}
