//
//  MockKeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import SwiftyUserDefaults

class MockKeyValueStorage {
    
    var currentUserProperties: UserDefaultsUser?
    
    fileprivate var keyValue = Dictionary<String, Any>()
}


// MARK: - KeyValueStorageable

extension MockKeyValueStorage: KeyValueStorageable {
    subscript(key: DefaultsKey<String?>) -> String? {
        get { return keyValue[key._key] as? String }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<String>) -> String {
        get { return keyValue[key._key] as? String ?? "" }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Int?>) -> Int? {
        get { return keyValue[key._key] as? Int }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return keyValue[key._key] as? Int ?? Int.min }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Double?>) -> Double? {
        get { return keyValue[key._key] as? Double }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Double>) -> Double {
        get { return keyValue[key._key] as? Double ?? 0 }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Bool?>) -> Bool? {
        get { return keyValue[key._key] as? Bool }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return keyValue[key._key] as? Bool ?? false }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Any?>) -> Any? {
        get { return keyValue[key._key] as Any? }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSObject?>) -> NSObject? {
        get { return keyValue[key._key] as? NSObject }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Data?>) -> Data? {
        get { return keyValue[key._key] as? Data }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Data>) -> Data {
        get { return keyValue[key._key] as? Data ?? Data() }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<Date?>) -> Date? {
        get { return keyValue[key._key] as? Date }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<URL?>) -> URL? {
        get {
            guard let urlString = keyValue[key._key] as? String else { return nil }
            return URL(string: urlString)
        }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? {
        get { return keyValue[key._key] as? [String: Any] }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] {
        get { return keyValue[key._key] as? [String: Any] ?? [String: Any]() }
        set { keyValue[key._key] = newValue }
    }

    subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return keyValue[key._key] as? [String] ?? [String]() }
        set { keyValue[key._key] = newValue }
    }
    func get<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>) -> T? {
        guard let dict = keyValue[key._key] as? [String: Any] else { return nil }
        return T.decode(dict)
    }
    func set<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>, value: T?) {
        let object = value?.encode()
        keyValue[key._key] = object
    }
}
