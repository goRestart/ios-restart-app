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
    let userDefaults: UserDefaults

    lazy var token: Token = {
        return self.fetch()
    }()

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
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
        self.token = token
    }

    func get(level: AuthLevel) -> Token? {
        switch level {
        case .nonexistent:
            return Token(value: nil, level: .nonexistent)
        case .installation:
            if let installationToken = userDefaults.string(forKey: TokenUserDefaultsDAO.installationKey) {
                return Token(value: installationToken, level: .installation)
            }
        case .user:
            if let userToken = userDefaults.string(forKey: TokenUserDefaultsDAO.userKey) {
                return Token(value: userToken, level: .user)
            }
        }
        return nil
    }

    func deleteInstallationToken() {
        userDefaults.removeObject(forKey: TokenUserDefaultsDAO.installationKey)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Deleted \(AuthLevel.installation) token from UserDefaults")
        token = fetch()
    }

    func deleteUserToken() {
        userDefaults.removeObject(forKey: TokenUserDefaultsDAO.userKey)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Deleted \(AuthLevel.user) token from UserDefaults")
        token = fetch()
    }

    private func storeToken(_ token: Token) {
        guard let tokenString = token.value else { return } // Already checked before the call, no need to log

        let key: String
        switch token.level {
        case .nonexistent:
            return
        case .installation:
            key = TokenUserDefaultsDAO.installationKey
        case .user:
            key = TokenUserDefaultsDAO.userKey
        }

        userDefaults.set(tokenString, forKey: key)
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "Stored \(token.level) token in UserDefaults")
    }

    private func fetch() -> Token {
        if let userToken = get(level: .user) {
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Fetched \(userToken.level) token: \(String(describing: userToken.value)) from UserDefaults")
            return userToken
        }
        if let installationToken = get(level: .installation) {
            logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                       message: "Fetched \(installationToken.level) token: \(String(describing: installationToken.value)) from UserDefaults")
            return installationToken
        }
        logMessage(.verbose, type: [CoreLoggingOptions.persistence, CoreLoggingOptions.token],
                   message: "No fetched token from UserDefaults")
        return Token(value: nil, level: .nonexistent)
    }
}
