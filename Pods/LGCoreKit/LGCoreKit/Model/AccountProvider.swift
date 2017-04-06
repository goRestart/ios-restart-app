//
//  AccountProvider.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

public enum AccountProvider: String {
    case email = "letgo"
    case facebook = "facebook"
    case google = "google"

    public static let allValues: [AccountProvider] = [.email, .facebook, .google]
}

extension AccountProvider: Decodable {}
