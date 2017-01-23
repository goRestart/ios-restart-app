//
//  KeychainChecker.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import Security

protocol BooleanDao {
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
}

extension UserDefaults: BooleanDao {}

class KeychainChecker {

    private static let settingsKey = "god_mode_cleanup_keychain"

    static func checkKeychain() {
        return KeychainChecker.checkKeychain(booleanDao: UserDefaults.standard, keychainCleaner: LGKeychainCleaner.self)
    }

    static func checkKeychain(booleanDao: BooleanDao, keychainCleaner: KeychainCleaner.Type) {
        #if GOD_MODE
        let shouldClean = booleanDao.bool(forKey: KeychainChecker.settingsKey)
        guard shouldClean else { return }
        keychainCleaner.cleanKeychain()
        booleanDao.set(false, forKey: KeychainChecker.settingsKey)
        #endif
    }
}

protocol KeychainCleaner {
    @discardableResult
    static func cleanKeychain() -> Bool
}

class LGKeychainCleaner: KeychainCleaner {

    static func cleanKeychain() -> Bool {
        let query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        return SecItemDelete(query as CFDictionary) == noErr
    }
}
