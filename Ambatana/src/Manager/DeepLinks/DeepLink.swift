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
    case Conversations
    case Conversation(data: ConversationData)
    case Message(messageType: Int, data: ConversationData)
    case Search(query: String)
    case ResetPassword(token: String)
}

enum ConversationData {
    case Conversation(conversationId: String)
    case ProductBuyer(productId: String, buyerId: String)
}