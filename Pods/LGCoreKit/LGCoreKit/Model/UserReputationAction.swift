//
//  UserReputationItem.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 10/4/18.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

public enum UserReputationActionType: String {
    case facebook = "verified_facebook"
    case google = "verified_google"
    case avatarUpdated = "user_avatar_updated"
    case markAsSold = "product_sold"
    case sms = "verified_sms"
    case email = "verified_letgo"
    case bio = "user_biography_updated"
    case unknown
}

public protocol UserReputationAction {
    var type: UserReputationActionType { get }
    var points: Int { get }
    var createdAt: Date? { get }
}
