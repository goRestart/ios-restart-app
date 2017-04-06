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
    case email(email: String)
    case facebook(facebookToken: String)
    case google(googleToken: String)

    var accountProvider: AccountProvider {
        switch self {
        case .email:
            return .email
        case .facebook:
            return .facebook
        case .google:
            return .google
        }
    }
}
