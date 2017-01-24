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

    private let booleanDao: BooleanDao
    private let keychainCleaner: KeychainCleaner
    private let enabled: Bool

    convenience init() {
        #if GOD_MODE
        let enabled = true
        #else
        let enabled = false
        #endif
        self.init(booleanDao: UserDefaults.standard, keychainCleaner: LGKeychainCleaner(), enabled: enabled)
    }

    init(booleanDao: BooleanDao, keychainCleaner: KeychainCleaner, enabled: Bool) {
        self.booleanDao = booleanDao
        self.keychainCleaner = keychainCleaner
        self.enabled = enabled
    }

    func checkKeychain() {
        guard enabled else { return }
        let shouldClean = booleanDao.bool(forKey: KeychainChecker.settingsKey)
        guard shouldClean else { return }
        keychainCleaner.cleanKeychain()
        booleanDao.set(false, forKey: KeychainChecker.settingsKey)
    }
}

protocol KeychainCleaner {
    @discardableResult
    func cleanKeychain() -> Bool
}

class LGKeychainCleaner: KeychainCleaner {
    func cleanKeychain() -> Bool {
        let query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        return SecItemDelete(query as CFDictionary) == noErr
    }
}
