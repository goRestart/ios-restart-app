//
//  UserRating.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol UserRating: BaseModel {
    var userToId: String { get }
    var userFrom: User { get }
    var type: UserRatingType { get }
    var value: Int { get }
    var comment: String? { get }
    var status: UserRatingStatus { get }
    var createdAt: NSDate { get }
    var updatedAt: NSDate { get }
}

public enum UserRatingType {
    case Conversation
    case Seller(productId: String)
    case Buyer(productId: String)
}

public enum UserRatingStatus: Int {
    case Published = 1
    case PendingReview = 2
    case Deleted = 3
}
