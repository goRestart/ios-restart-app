//
//  UserStatus.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//
import Argo

public enum UserStatus: String {
    case Active = "active"
    case Inactive = "inactive"
    case PendingDelete = "to_be_deleted"
    case Deleted = "deleted"
    case Scammer = "scammer"
    case NotFound = "not_found"

    public static let allValues: [UserStatus] = [.Active, .Inactive, .Deleted, .Scammer, .NotFound]
}

extension UserStatus: Decodable {}
