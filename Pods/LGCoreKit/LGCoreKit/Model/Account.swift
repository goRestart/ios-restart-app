//
//  Account.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol Account {
    var provider: AccountProvider { get }
    var verified: Bool { get }
}
