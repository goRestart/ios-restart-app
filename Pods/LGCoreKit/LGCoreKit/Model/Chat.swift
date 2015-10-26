//
//  Chat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol Chat: BaseModel {
    var product: Product? { get set }
    var userFrom: User? { get set }
    var userTo: User? { get set }
    var msgUnreadCount: Int? { get set }
    var messages: [Message]? { get set }
}
