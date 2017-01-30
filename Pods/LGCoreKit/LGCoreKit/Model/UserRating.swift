//
//  UserRating.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 14/07/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol UserRating: BaseModel {
    var userToId: String { get }
    var userFrom: UserProduct { get }
    var type: UserRatingType { get }
    var value: Int { get }
    var comment: String? { get }
    var status: UserRatingStatus { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

public enum UserRatingType {
    case conversation
    case seller(productId: String)
    case buyer(productId: String)
}

public enum UserRatingStatus: Int {
    case published = 1
    case pendingReview = 2
    case deleted = 3
}
