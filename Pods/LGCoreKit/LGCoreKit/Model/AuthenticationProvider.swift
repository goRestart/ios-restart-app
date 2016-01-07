//
//  AuthenticationProvider.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 23/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

public enum AuthenticationProvider: String {
    case Unknown = "Unknown"
    case Email = "Email"
    case Facebook = "Facebook"

    static let allValues: [AuthenticationProvider] = [.Unknown, .Email, .Facebook]
}
