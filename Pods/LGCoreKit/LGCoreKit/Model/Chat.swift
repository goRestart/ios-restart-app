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

public enum ChatArchivedStatus: Int {
    case Active = 0
    case BuyerArchived = 1
    case SellerArchived = 2
    case BothArchived = 3
}

public protocol Chat: BaseModel {
    var product: Product { get }
    var userFrom: User { get }
    var userTo: User { get }
    var msgUnreadCount: Int { get }     // Default: 0
    var messages: [Message] { get }     // Default: []
    var updatedAt: NSDate? { get }
    var forbidden: Bool { get }
    var archivedStatus: ChatArchivedStatus { get }
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
        case .Deleted, .Discarded:
            return .Deleted
        case .Sold, .SoldOld:
            return .Sold
        case .Approved, .Pending:
            return .Available
        }
    }

    public var buyer: User {
        guard let productOwnerId = product.user.objectId, userFromId = userFrom.objectId else { return userFrom }
        return productOwnerId == userFromId ? userTo : userFrom
    }

    public var seller: User {
        guard let productOwnerId = product.user.objectId, userFromId = userFrom.objectId else { return userFrom }
        return productOwnerId == userFromId ? userFrom : userTo
    }

    public func otherUser(myUser myUser: MyUser) -> User {
        guard let myUserId = myUser.objectId, userFromId = userFrom.objectId else { return userFrom }
        return myUserId == userFromId ? userTo : userFrom
    }

    public func isArchived(myUser myUser: MyUser)  -> Bool {
        switch archivedStatus {
        case .Active:
            return false
        case .BuyerArchived:
            return myUser.objectId == buyer.objectId
        case .SellerArchived:
            return myUser.objectId == seller.objectId
        case .BothArchived:
            return true
        }
    }
}
