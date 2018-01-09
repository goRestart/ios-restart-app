//
//  UserStatus.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum UserStatus: String, Decodable {
    case active = "active"
    case inactive = "inactive"
    case pendingDelete = "to_be_deleted"
    case deleted = "deleted"
    case scammer = "scammer"
    case notFound = "not_found"

    public static let allValues: [UserStatus] = [.active, .inactive, .deleted, .scammer, .notFound]
}
