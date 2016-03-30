//
//  ChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatConversation: BaseModel {
    var unreadMessageCount: Int { get }
    var lastMessageSentAt: NSDate? { get }
    var product: ChatProduct { get }
    var interlocutor: ChatInterlocutor { get }
}
