//
//  ChatConversation.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatConversation: BaseModel {
    var unreadMessageCount: Int { get }
    var lastMessageSentAt: Date? { get }
    var product: ChatListing? { get }
    var interlocutor: ChatInterlocutor? { get }
    var amISelling: Bool { get }
}
