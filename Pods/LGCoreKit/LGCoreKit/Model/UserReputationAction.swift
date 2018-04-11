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
    case avatarUploaded = "avatar_uploaded"
    case markAsSold = "mark_as_sold"
    case sms = "verified_sms"
    case email = "verified_email"
    case unknown
}

public protocol UserReputationAction {
    var id: String { get }
    var type: UserReputationActionType { get }
    var points: Int { get }
    var createdAt: Date? { get }
}
