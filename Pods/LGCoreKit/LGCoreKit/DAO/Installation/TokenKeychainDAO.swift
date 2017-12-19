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
    let keychain: Keychainable

    var currentInstallationToken: Token?
    var currentUserToken: Token?

    var token: Token {
        return currentUserToken ?? currentInstallationToken ?? Token(value: nil, level: .nonexistent)
    }

    init(keychain: Keychainable) {
        self.keychain = keychain
        self.fetch()
    }

    func save(_ token: Token) {
        guard let _ = token.value else {
            logMessage(.error, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Keychain: Token won't be saved as it has no value, level: \(token.level)")
            return
        }
        storeToken(token)
        if token.level < self.token.level {
            logMessage(.warning, type: [CoreLoggingOptions.token],
                message: "Keychain: Token won't be stored in memory as its level \(token.level) < current \(self.token.level), value: \(String(describing: token.value))")
            return
        }
        logMessage(.verbose, type: [CoreLoggingOptions.token], message: "Keychain: \(token.level) token saved in-memory")
    }

    func get(level: AuthLevel) -> Token? {
        switch level {
        case .nonexistent:
            return Token(value: nil, level: .nonexistent)
        case .installation:
            return currentInstallationToken
        case .user:
            return currentUserToken
        }
    }

    func deleteInstallationToken() {
        currentInstallationToken = nil
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.installationKey)
        if deleteSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Succeeded deleting \(AuthLevel.installation) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Failed deleting \(AuthLevel.installation) token in keychain")
        }
    }

    func deleteUserToken() {
        currentUserToken = nil
        let deleteSucceeded = keychain.delete(TokenKeychainDAO.userKey)
        if deleteSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Succeeded deleting \(AuthLevel.user) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Failed deleting \(AuthLevel.user) token in keychain")
        }
    }

    private func storeToken(_ token: Token) {
        guard let tokenString = token.value else { return } // Already checked before the call no need to log

        let key: String
        switch token.level {
        case .nonexistent:
            return
        case .installation:
            key = TokenKeychainDAO.installationKey
            currentInstallationToken = token
        case .user:
            key = TokenKeychainDAO.userKey
            currentUserToken = token
        }

        let storeSucceeded = keychain.set(tokenString, forKey: key,
            withAccess: .accessibleAfterFirstUnlockThisDeviceOnly)
        if storeSucceeded {
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Succeeded storing \(token.level) token in keychain")
        } else {
            logMessage(.error, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Failed storing \(token.level) token with level in keychain")
        }
    }

    private func fetch() {
        if let userTokenValue = keychain.get(TokenKeychainDAO.userKey) {
            let userToken = Token(value: userTokenValue, level: .user)
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Fetched \(userToken.level) token: \(String(describing: userToken.value))")
            currentUserToken = userToken
        }
        if let installationTokenValue = keychain.get(TokenKeychainDAO.installationKey) {
            let installationToken = Token(value: installationTokenValue, level: .installation)
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                message: "Fetched \(installationToken.level) token: \(String(describing: installationToken.value))")
            currentInstallationToken = installationToken
        }
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
            message: "No fetched token")
    }
}
