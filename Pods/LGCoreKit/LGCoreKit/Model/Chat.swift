//
//  Chat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum ChatStatus {
    case Available
    case Forbidden
    case Sold
    case Deleted
}

public protocol Chat: BaseModel {
    var product: Product { get }
    var userFrom: User { get }
    var userTo: User { get }
    var msgUnreadCount: Int { get }     // Default: 0
    var messages: [Message] { get }     // Default: []
    var updatedAt: NSDate? { get }
    var forbidden: Bool { get }
    
    mutating func prependMessage( message: Message)
}


public extension Chat {
    public func didReceiveMessageFrom(userID: String) -> Bool {
        return messages.filter { $0.userId == userID }.count > 0
    }
}

public extension Chat {
    public var status: ChatStatus {
        if forbidden { return .Forbidden }
        switch product.status {
        case .Deleted:
            return .Deleted
        case .Sold, .SoldOld:
            return .Sold
        case .Approved, .Discarded, .Pending:
            return .Available
        }
    }
}
