//
//  KeychainChecker.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import Security

class GodModeManager {

    static let sharedInstance: GodModeManager = GodModeManager()

    private enum GodModeKey: String {
        case fullCleanStart = "god_mode_full_cleanup"
        case reinstallCleanStart = "god_mode_reinstall_cleanup"
        case keychainClean = "god_mode_cleanup_keychain"
    }

    private let booleanDAO: BooleanDAO
    private let storageCleaner: StorageCleaner
    private let enabled: Bool

    convenience init() {
        #if GOD_MODE
        let enabled = true
        #else
        let enabled = false
        #endif
        self.init(booleanDAO: UserDefaults.standard, storageCleaner: LGStorageCleaner(), enabled: enabled)
    }

    init(booleanDAO: BooleanDAO, storageCleaner: StorageCleaner, enabled: Bool) {
        self.booleanDAO = booleanDAO
        self.storageCleaner = storageCleaner
        self.enabled = enabled
    }

    func setCleanInstallOnNextStart(keepingInstallation: Bool) {
        set(key: keepingInstallation ? .reinstallCleanStart : .fullCleanStart, enabled: true)
    }

    func applicationDidFinishLaunching() {
        if checkFullClean() { return }
        if checkReInstallClean() { return }
        checkKeychain()
    }

    private func checkFullClean() -> Bool {
        guard keyEnabled(.fullCleanStart) else { return false }
        storageCleaner.cleanKeychain()
        storageCleaner.cleanKeyValueStorage()
        return true
    }

    private func checkReInstallClean() -> Bool {
        guard keyEnabled(.reinstallCleanStart) else { return false }
        storageCleaner.cleanKeyValueStorage()
        return true
    }

    private func checkKeychain() {
        guard keyEnabled(.keychainClean) else { return }
        storageCleaner.cleanKeychain()
        set(key: .keychainClean, enabled: false)
    }

    private func keyEnabled(_ key: GodModeKey) -> Bool {
        guard enabled else { return false }
        let keyEnabled = booleanDAO.bool(forKey: key.rawValue)
        return keyEnabled
    }

    private func set(key: GodModeKey, enabled: Bool) {
        guard enabled else { return }
        booleanDAO.set(enabled, forKey: key.rawValue)
    }
}

protocol StorageCleaner {
    @discardableResult
    func cleanKeychain() -> Bool
    @discardableResult
    func cleanKeyValueStorage() -> Bool
}

class LGStorageCleaner: StorageCleaner {
    func cleanKeychain() -> Bool {
        let query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        return SecItemDelete(query as CFDictionary) == noErr
    }

    func cleanKeyValueStorage() -> Bool {
        guard let appDomain = Bundle.main.bundleIdentifier else { return false }
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        return true
    }
}
