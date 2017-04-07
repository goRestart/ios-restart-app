//
//  TokenCleanupDAO.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 07/04/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//



/// Proxy token dao that will use primaryDAO and will remove all tokens from toDeleteDAO
class TokenCleanupDAO: TokenDAO {

    private let primaryDAO: TokenDAO

    var token: Token {
        return primaryDAO.token
    }


    /// TokenCleanupDAO init
    ///
    /// - Parameters:
    ///   - primaryDAO: dao that will be used to store and read tokens
    ///   - toDeleteDAO: dao to cleanup on init
    init(primaryDAO: TokenDAO, toDeleteDAO: TokenDAO) {
        self.primaryDAO = primaryDAO
        toDeleteDAO.deleteUserToken()
        toDeleteDAO.deleteInstallationToken()
    }

    func save(_ token: Token) {
        primaryDAO.save(token)
    }

    func get(level: AuthLevel) -> Token? {
        return primaryDAO.get(level: level)
    }

    func deleteInstallationToken() {
        primaryDAO.deleteInstallationToken()
    }

    func deleteUserToken() {
        primaryDAO.deleteUserToken()
    }
}

