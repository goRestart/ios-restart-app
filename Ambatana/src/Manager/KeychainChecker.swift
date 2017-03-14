//
//  KeychainChecker.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import Security

class KeychainChecker {

    private static let settingsKey = "god_mode_cleanup_keychain"

    private let booleanDAO: BooleanDAO
    private let keychainCleaner: KeychainCleaner
    private let enabled: Bool

    convenience init() {
        #if GOD_MODE
        let enabled = true
        #else
        let enabled = false
        #endif
        self.init(booleanDAO: UserDefaults.standard, keychainCleaner: LGKeychainCleaner(), enabled: enabled)
    }

    init(booleanDAO: BooleanDAO, keychainCleaner: KeychainCleaner, enabled: Bool) {
        self.booleanDAO = booleanDAO
        self.keychainCleaner = keychainCleaner
        self.enabled = enabled
    }

    func checkKeychain() {
        guard enabled else { return }
        let shouldClean = booleanDAO.bool(forKey: KeychainChecker.settingsKey)
        guard shouldClean else { return }
        keychainCleaner.cleanKeychain()
        booleanDAO.set(false, forKey: KeychainChecker.settingsKey)
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
