//
//  NSUserDefaults+KeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

class StorageableUserDefaults: KeyValueStorageable {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    subscript(key: DefaultsKey<String?>) -> String? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<String>) -> String {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Int?>) -> Int? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Double?>) -> Double? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Double>) -> Double {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Any?>) -> Any? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Data?>) -> Data? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Data>) -> Data {
        get { return userDefaults[key] as Data }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<Date?>) -> Date? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<URL?>) -> URL? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return userDefaults[key] }
        set { userDefaults[key] = newValue }
    }
    func get<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>) -> T? {
        guard let dict = userDefaults.dictionary(forKey: key._key) else { return nil }
        return T.decode(dict)
    }
    func set<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>, value: T?) {
        let object = value?.encode()
        userDefaults.set(object, forKey: key._key)
    }
}
