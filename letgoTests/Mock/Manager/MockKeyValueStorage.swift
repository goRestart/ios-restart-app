//
//  MockKeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import SwiftyUserDefaults

class MockKeyValueStorage {
    private var keyValue = Dictionary<String, AnyObject>()
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
    subscript(key: DefaultsKey<NSString?>) -> NSString? {
        get { return keyValue[key._key] as? NSString }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSString>) -> NSString {
        get { return keyValue[key._key] as? NSString ?? "" }
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
        get { return keyValue[key._key] as? Double ?? Double.NaN }
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
    subscript(key: DefaultsKey<AnyObject?>) -> AnyObject? {
        get { return keyValue[key._key] }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSObject?>) -> NSObject? {
        get { return keyValue[key._key] as? NSObject }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSData?>) -> NSData? {
        get { return keyValue[key._key] as? NSData }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSData>) -> NSData {
        get { return keyValue[key._key] as? NSData ?? NSData() }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSDate?>) -> NSDate? {
        get { return keyValue[key._key] as? NSDate }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSURL?>) -> NSURL? {
        get {
            guard let urlString = keyValue[key._key] as? String else { return nil }
            return NSURL(string: urlString)
        }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<[String: AnyObject]?>) -> [String: AnyObject]? {
        get { return keyValue[key._key] as? [String: AnyObject] }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<[String: AnyObject]>) -> [String: AnyObject] {
        get { return keyValue[key._key] as? [String: AnyObject] ?? [String: AnyObject]() }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? {
        get { return keyValue[key._key] as? NSDictionary }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<NSDictionary>) -> NSDictionary {
        get { return keyValue[key._key] as? NSDictionary ?? NSDictionary() }
        set { keyValue[key._key] = newValue }
    }
    subscript(key: DefaultsKey<[String]>) -> [String] {
        get { return keyValue[key._key] as? [String] ?? [String]() }
        set { keyValue[key._key] = newValue }
    }
    func get<T: UserDefaultsDecodable>(key: DefaultsKey<T>) -> T? {
        guard let dict = keyValue[key._key] as? [String: AnyObject] else { return nil }
        return T.decode(dict)
    }
    func set<T: UserDefaultsDecodable>(key: DefaultsKey<T>, value: T?) {
        let object = value?.encode()
        keyValue[key._key] = object
    }
}
