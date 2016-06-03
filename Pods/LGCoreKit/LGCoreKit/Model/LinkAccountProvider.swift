//
//  LinkAccountProvider.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 31/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

/**
 Defines the LinkAccountProvider in letgo API.
 */
enum LinkAccountProvider {
    case Email(email: String)
    case Facebook(facebookToken: String)
    case Google(googleToken: String)

    var accountProvider: AccountProvider {
        switch self {
        case .Email:
            return .Email
        case .Facebook:
            return .Facebook
        case .Google:
            return .Google
        }
    }
}
