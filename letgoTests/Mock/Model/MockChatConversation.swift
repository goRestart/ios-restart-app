//
//  MockChatConversation.swift
//  LetGo
//
//  Created by Juan Iglesias on 31/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import LGCoreKit

class MockChatConversation: MockBaseModel, ChatConversation {
    
    // Chat iVars
    var unreadMessageCount: Int
    var lastMessageSentAt: Date?
    var product: ChatProduct?
    var interlocutor: ChatInterlocutor?
    var amISelling: Bool
    
    // Lifecycle
    
    override init() {
        
        self.unreadMessageCount = 0
        self.lastMessageSentAt = Date()
        self.product = nil
        self.interlocutor = nil
        self.amISelling = false
        super.init()
    }
    
    required init(unreadMessage: Int, lastMessageSentAt: Date?, product: ChatProduct?, interlocutor: ChatInterlocutor?, amISelling: Bool) {
        self.unreadMessageCount = unreadMessage
        self.lastMessageSentAt = lastMessageSentAt
        self.product = product
        self.interlocutor = interlocutor
        self.amISelling = amISelling
    }
}
