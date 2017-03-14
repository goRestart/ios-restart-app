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

    var lastGetKey: String? = nil
    var getValue: Bool = false
    var lastSetKey: String? = nil
    var lastSetValue: Bool? = nil


    func bool(forKey defaultName: String) -> Bool {
        lastGetKey = defaultName
        return getValue
    }
    func set(_ value: Bool, forKey defaultName: String) {
        lastSetKey = defaultName
        lastSetValue = value
    }
}

class MockKeychainCleaner: KeychainCleaner {

    var calledClean: Bool = false

    func cleanKeychain() -> Bool {
        calledClean = true
        return true
    }
}
