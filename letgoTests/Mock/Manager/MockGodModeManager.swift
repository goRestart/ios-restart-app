//
//  MockKeychainChecker.swift
//  LetGo
//
//  Created by Eli Kohen on 23/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Foundation

class MockBooleanDAO: BooleanDAO {

    var values: [String: Bool] = [:]

    var lastGetKey: String? = nil
    var lastSetKey: String? = nil
    var lastSetValue: Bool? = nil


    func bool(forKey key: String) -> Bool {
        lastGetKey = key
        return values[key] ?? false
    }
    func set(_ value: Bool, forKey key: String) {
        lastSetKey = key
        lastSetValue = value
        values[key] = value
    }
}

class MockStorageCleaner: StorageCleaner {

    var calledCleanKeychain: Bool = false
    var calledCleanKeyValueStorage: Bool = false

    func cleanKeychain() -> Bool {
        calledCleanKeychain = true
        return true
    }

    func cleanKeyValueStorage() -> Bool {
        calledCleanKeyValueStorage = true
        return true
    }
}
