//
//  Chat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol Chat: BaseModel {
    var product: Product { get }
    var userFrom: User { get }
    var userTo: User { get }
    var msgUnreadCount: Int { get }     // Default: 0
    var messages: [Message] { get }     // Default: []
    var updatedAt: NSDate? { get }
    
    mutating func prependMessage( message: Message)
}