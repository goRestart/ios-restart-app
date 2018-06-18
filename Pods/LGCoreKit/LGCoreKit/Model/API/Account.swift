//
//  Account.swift
//  LGCoreKit
//
//  Created by Nestor on 27/10/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public enum AccountProvider: String, Decodable {
    case email = "letgo"
    case passwordless = "letgo-passwordless"
    case facebook = "facebook"
    case google = "google"
    
    public static let allValues: [AccountProvider] = [.email, .passwordless, .facebook, .google]
}

public protocol Account {
    var provider: AccountProvider { get }
    var verified: Bool { get }
}
