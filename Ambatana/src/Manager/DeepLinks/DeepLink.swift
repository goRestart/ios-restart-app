//
//  DeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum DeepLink {
    case Home
    case Sell
    case Product(productId: String)
    case User(userId: String)
    case Chats
    case Chat(productId: String, buyerId: String)
    case Conversation(conversationId: String)
    case Search(query: String)
    case ResetPassword(token: String)
}