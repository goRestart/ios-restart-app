//
//  AccountProvider.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

public enum AccountProvider: String {
    case Email = "letgo"
    case Facebook = "facebook"
    case Google = "google"

    public static let allValues: [AccountProvider] = [.Email, .Facebook, .Google]
}

extension AccountProvider: Decodable {}
