//
//  TokenRedundanceDAO.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 24/01/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

class TokenRedundanceDAO: TokenDAO {

    private let primaryDAO: TokenDAO
    private let secondaryDAO: TokenDAO

    private var shouldCheckMigration = true

    var token: Token {
        migrateIfNeeded()
        return primaryDAO.token
    }

    init(primaryDAO: TokenDAO, secondaryDAO: TokenDAO) {
        self.primaryDAO = primaryDAO
        self.secondaryDAO = secondaryDAO
    }

    func save(_ token: Token) {
        primaryDAO.save(token)
        secondaryDAO.save(token)
    }

    func get(level: AuthLevel) -> Token? {
        migrateIfNeeded()
        return primaryDAO.get(level: level)
    }

    func deleteInstallationToken() {
        primaryDAO.deleteInstallationToken()
        secondaryDAO.deleteInstallationToken()
    }

    func deleteUserToken() {
        primaryDAO.deleteUserToken()
        secondaryDAO.deleteUserToken()
    }


    private func migrateIfNeeded() {
        guard shouldCheckMigration else { return }
        shouldCheckMigration = false
        if primaryDAO.level == .nonexistent && secondaryDAO.level > .nonexistent {
            if let installationToken = secondaryDAO.get(level: .installation) {
                primaryDAO.save(installationToken)
            }
            if let userToken = secondaryDAO.get(level: .user) {
                primaryDAO.save(userToken)
            }
        } else if primaryDAO.level > .nonexistent {
            secondaryDAO.reset()
            if let installationToken = primaryDAO.get(level: .installation) {
                secondaryDAO.save(installationToken)
            }
            if let userToken = primaryDAO.get(level: .user) {
                secondaryDAO.save(userToken)
            }
        }
    }
}
