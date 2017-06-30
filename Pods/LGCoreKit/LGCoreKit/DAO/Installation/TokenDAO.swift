//
//  TokenDAO.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

protocol TokenDAO {
    var token: Token { get }
    var currentInstallationToken: Token? { get }
    var currentUserToken: Token? { get }
    func save(_ token: Token)
    func get(level: AuthLevel) -> Token?
    func reset()
    func deleteInstallationToken()
    func deleteUserToken()
}

extension TokenDAO {
    var level: AuthLevel {
        return token.level
    }
    var value: String? {
        return token.value
    }

    func reset() {
        deleteInstallationToken()
        deleteUserToken()
    }
}
