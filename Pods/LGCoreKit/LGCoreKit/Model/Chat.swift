//
//  Chat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum ChatStatus {
    case available
    case forbidden
    case sold
    case deleted
}

public enum ChatArchivedStatus: Int {
    case active = 0
    case buyerArchived = 1
    case sellerArchived = 2
    case bothArchived = 3
}

public protocol Chat: BaseModel {
    var listing: Listing { get }
    var userFrom: UserListing { get }
    var userTo: UserListing { get }
    var msgUnreadCount: Int { get }     // Default: 0
    var messages: [Message] { get }     // Default: []
    var updatedAt: Date? { get }
    var forbidden: Bool { get }
    var archivedStatus: ChatArchivedStatus { get }
}


public extension Chat {
    public func didReceiveMessageFrom(_ userID: String) -> Bool {
        return messages.filter { $0.userId == userID }.count > 0
    }
}

public extension Chat {
    public var status: ChatStatus {
        if forbidden { return .forbidden }
        switch listing.status {
        case .deleted, .discarded:
            return .deleted
        case .sold, .soldOld:
            return .sold
        case .approved, .pending:
            return .available
        }
    }

    public var buyer: UserListing {
        guard let listingOwnerId = listing.user.objectId, let userFromId = userFrom.objectId else { return userFrom }
        return listingOwnerId == userFromId ? userTo : userFrom
    }

    public var seller: UserListing {
        guard let listingOwnerId = listing.user.objectId, let userFromId = userFrom.objectId else { return userFrom }
        return listingOwnerId == userFromId ? userFrom : userTo
    }

    public func otherUser(myUser: MyUser) -> UserListing {
        guard let myUserId = myUser.objectId, let userFromId = userFrom.objectId else { return userFrom }
        return myUserId == userFromId ? userTo : userFrom
    }

    public func isArchived(myUser: MyUser)  -> Bool {
        switch archivedStatus {
        case .active:
            return false
        case .buyerArchived:
            return myUser.objectId == buyer.objectId
        case .sellerArchived:
            return myUser.objectId == seller.objectId
        case .bothArchived:
            return true
        }
    }
}
