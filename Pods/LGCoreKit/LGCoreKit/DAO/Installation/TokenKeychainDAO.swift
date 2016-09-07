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

    func save(token: Token) {
        guard let _ = token.value else {
            logMessage(.Error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Token won't be saved as it has no value, level: \(token.level)")
            return
        }
        storeToken(token)
        if token.level < self.token.level {
            logMessage(.Warning, type: [CoreLoggingOptions.Token],
                message: "Token won't be saved as its level \(token.level) < current \(self.token.level), value: \(token.value)")
            return
        }
        logMessage(.Verbose, type: [CoreLoggingOptions.Token], message: "\(token.level) token saved in-memory")
        self.token = token
    }

    func get(level level: AuthLevel) -> Token? {
        switch level {
        case .None:
            return Token(value: nil, level: .None)
        case .Installation:
            if let installationToken = keychain.get(TokenKeychainDAO.installationKey) {
                return Token(value: installationToken, level: .Installation)
            }
        case .User:
            if let userToken = keychain.get(TokenKeychainDAO.userKey) {
                return Token(value: userToken, level: .User)
            }
        }
        return nil
    }

    func deleteInstallationToken() {
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.installationKey)
        if deleteSucceeded {
            logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                       message: "Succeeded deleting \(AuthLevel.Installation) token in keychain")
        } else {
            logMessage(.Error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                       message: "Failed deleting \(AuthLevel.Installation) token in keychain")
        }
        token = fetch()
    }

    func deleteUserToken() {
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.userKey)
        if deleteSucceeded {
            logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Succeeded deleting \(AuthLevel.User) token in keychain")
        } else {
            logMessage(.Error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Failed deleting \(AuthLevel.User) token in keychain")
        }
        token = fetch()
    }

    private func storeToken(token: Token) {
        guard let tokenString = token.value else {
            logMessage(.Verbose, type: [CoreLoggingOptions.Token],
                message: "Token won't be updated in memory as its level \(token.level) < current \(self.token.level)")
            return
        }

        let key: String
        switch token.level {
        case .None:
            return
        case .Installation:
            key = TokenKeychainDAO.installationKey
        case .User:
            key = TokenKeychainDAO.userKey
        }

        let storeSucceeded = keychain.set(tokenString, forKey: key,
            withAccess: .AccessibleAfterFirstUnlockThisDeviceOnly)
        if storeSucceeded {
            logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Succeeded storing \(token.level) token in keychain")
        } else {
            logMessage(.Error, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Failed storing \(token.level) token with level in keychain")
        }
    }

    private func fetch() -> Token {
        if let userToken = get(level: .User) {
            logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Fetched \(userToken.level) token: \(userToken.value)")
            return userToken
        }
        if let installationToken = get(level: .Installation) {
            logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
                message: "Fetched \(installationToken.level) token: \(installationToken.value)")
            return installationToken
        }
        logMessage(.Verbose, type: [CoreLoggingOptions.Persistence, CoreLoggingOptions.Token],
            message: "No fetched token")
        return Token(value: nil, level: .None)
    }
}
