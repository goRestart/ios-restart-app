//
//  TokenUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 24/01/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

class TokenUserDefaultsDAO: TokenDAO {

    static let installationKey = "InstallationToken"
    static let userKey = "UserToken"
    let userDefaults: UserDefaultable

    var currentInstallationToken: Token?
    var currentUserToken: Token?

    var token: Token {
        return currentUserToken ?? currentInstallationToken ?? Token(value: nil, level: .nonexistent)
    }

    init(userDefaults: UserDefaultable) {
        self.userDefaults = userDefaults
        self.fetch()
    }

    func save(_ token: Token) {
        guard let _ = token.value else {
            logMessage(.error, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "UD: Token won't be saved as it has no value, level: \(token.level)")
            return
        }
        storeToken(token)
        if token.level < self.token.level {
            logMessage(.warning, type: [CoreLoggingOptions.token],
                       message: "UD: Token won't be saved as its level \(token.level) < current \(self.token.level), value: \(String(describing: token.value))")
            return
        }
        logMessage(.verbose, type: [CoreLoggingOptions.token], message: "UD: \(token.level) token saved in-memory")
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
        userDefaults.removeObject(forKey: TokenUserDefaultsDAO.installationKey)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Deleted \(AuthLevel.installation) token from UserDefaults")
    }

    func deleteUserToken() {
        currentUserToken = nil
        userDefaults.removeObject(forKey: TokenUserDefaultsDAO.userKey)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Deleted \(AuthLevel.user) token from UserDefaults")
    }

    private func storeToken(_ token: Token) {
        guard let tokenString = token.value else { return } // Already checked before the call, no need to log

        let key: String
        switch token.level {
        case .nonexistent:
            return
        case .installation:
            key = TokenUserDefaultsDAO.installationKey
            currentInstallationToken = token
        case .user:
            key = TokenUserDefaultsDAO.userKey
            currentUserToken = token
        }

        userDefaults.set(tokenString, forKey: key)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Stored \(token.level) token in UserDefaults")
    }

    private func fetch() {
        if let userTokenValue = userDefaults.string(forKey: TokenUserDefaultsDAO.userKey) {
            let userToken = Token(value: userTokenValue, level: .user)
            currentUserToken = userToken
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Fetched \(userToken.level) token: \(String(describing: userToken.value)) from UserDefaults")
        }
        if let installationTokenValue = userDefaults.string(forKey: TokenUserDefaultsDAO.installationKey) {
            let installationToken = Token(value: installationTokenValue, level: .installation)
            currentInstallationToken = installationToken
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Fetched \(installationToken.level) token: \(String(describing: installationToken.value)) from UserDefaults")
        }
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "No fetched token from UserDefaults")
    }
}
