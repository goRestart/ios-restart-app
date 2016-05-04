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
    func save(token: Token)
    func get(level level: AuthLevel) -> Token?
    func reset()
    func deleteUserToken()
}

extension TokenDAO {
    var level: AuthLevel {
        return token.level
    }
    var value: String? {
        return token.value
    }
}
