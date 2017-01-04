//
//  TokenKeychainDAO.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 15/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import KeychainSwift


class TokenKeychainDAO: TokenDAO {

    static let installationKey = "InstallationToken"
    static let userKey = "UserToken"
    let keychain: KeychainSwift

    lazy var token: Token = {
        return self.fetch()
    }()

    init(keychain: KeychainSwift) {
        self.keychain = keychain
    }

    func save(_ token: Token) {
        guard let _ = token.value else {
            logMessage(.error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Token won't be saved as it has no value, level: \(token.level)")
            return
        }
        storeToken(token)
        if token.level < self.token.level {
            logMessage(.warning, type: [CoreLoggingOptions.Token],
                message: "Token won't be saved as its level \(token.level) < current \(self.token.level), value: \(token.value)")
            return
        }
        logMessage(.verbose, type: [CoreLoggingOptions.Token], message: "\(token.level) token saved in-memory")
        self.token = token
    }

    func get(level: AuthLevel) -> Token? {
        switch level {
        case .nonexistent:
            return Token(value: nil, level: .nonexistent)
        case .installation:
            if let installationToken = keychain.get(TokenKeychainDAO.installationKey) {
                return Token(value: installationToken, level: .installation)
            }
        case .user:
            if let userToken = keychain.get(TokenKeychainDAO.userKey) {
                return Token(value: userToken, level: .user)
            }
        }
        return nil
    }

    func deleteInstallationToken() {
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.installationKey)
        if deleteSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                       message: "Succeeded deleting \(AuthLevel.installation) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                       message: "Failed deleting \(AuthLevel.installation) token in keychain")
        }
        token = fetch()
    }

    func deleteUserToken() {
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.userKey)
        if deleteSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Succeeded deleting \(AuthLevel.user) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Failed deleting \(AuthLevel.user) token in keychain")
        }
        token = fetch()
    }

    private func storeToken(_ token: Token) {
        guard let tokenString = token.value else {
            logMessage(.verbose, type: [CoreLoggingOptions.Token],
                message: "Token won't be updated in memory as its level \(token.level) < current \(self.token.level)")
            return
        }

        let key: String
        switch token.level {
        case .nonexistent:
            return
        case .installation:
            key = TokenKeychainDAO.installationKey
        case .user:
            key = TokenKeychainDAO.userKey
        }

        let storeSucceeded = keychain.set(tokenString, forKey: key,
            withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
        if storeSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Succeeded storing \(token.level) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Failed storing \(token.level) token with level in keychain")
        }
    }

    private func fetch() -> Token {
        if let userToken = get(level: .user) {
            logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Fetched \(userToken.level) token: \(userToken.value)")
            return userToken
        }
        if let installationToken = get(level: .installation) {
            logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Fetched \(installationToken.level) token: \(installationToken.value)")
            return installationToken
        }
        logMessage(.verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
            message: "No fetched token")
        return Token(value: nil, level: .nonexistent)
    }
}
