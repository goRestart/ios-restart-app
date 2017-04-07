//
//  KeyValueStorageable.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

protocol KeyValueStorageable: class {
    subscript(key: DefaultsKey<String?>) -> String? { get set }
    subscript(key: DefaultsKey<String>) -> String { get set }
    subscript(key: DefaultsKey<Int?>) -> Int? { get set }
    subscript(key: DefaultsKey<Int>) -> Int { get set }
    subscript(key: DefaultsKey<Double?>) -> Double? { get set }
    subscript(key: DefaultsKey<Double>) -> Double { get set }
    subscript(key: DefaultsKey<Bool?>) -> Bool? { get set }
    subscript(key: DefaultsKey<Bool>) -> Bool { get set }
    subscript(key: DefaultsKey<Any?>) -> Any? { get set }
    subscript(key: DefaultsKey<Data?>) -> Data? { get set }
    subscript(key: DefaultsKey<Data>) -> Data { get set }
    subscript(key: DefaultsKey<Date?>) -> Date? { get set }
    subscript(key: DefaultsKey<URL?>) -> URL? { get set }
    subscript(key: DefaultsKey<[String: Any]?>) -> [String: Any]? { get set }
    subscript(key: DefaultsKey<[String: Any]>) -> [String: Any] { get set }
    subscript(key: DefaultsKey<[String]>) -> [String] { get set }

    func get<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>) -> T?
    func set<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>, value: T?)
    
    var currentUserProperties: UserDefaultsUser? { get set }
}
