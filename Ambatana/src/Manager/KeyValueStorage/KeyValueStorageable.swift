//
//  KeyValueStorageable.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

protocol KeyValueStorageable {
    subscript(key: DefaultsKey<String?>) -> String? { get set }
    subscript(key: DefaultsKey<String>) -> String { get set }
    subscript(key: DefaultsKey<NSString?>) -> NSString? { get set }
    subscript(key: DefaultsKey<NSString>) -> NSString { get set }
    subscript(key: DefaultsKey<Int?>) -> Int? { get set }
    subscript(key: DefaultsKey<Int>) -> Int { get set }
    subscript(key: DefaultsKey<Double?>) -> Double? { get set }
    subscript(key: DefaultsKey<Double>) -> Double { get set }
    subscript(key: DefaultsKey<Bool?>) -> Bool? { get set }
    subscript(key: DefaultsKey<Bool>) -> Bool { get set }
    subscript(key: DefaultsKey<AnyObject?>) -> AnyObject? { get set }
    subscript(key: DefaultsKey<NSObject?>) -> NSObject? { get set }
    subscript(key: DefaultsKey<NSData?>) -> NSData? { get set }
    subscript(key: DefaultsKey<NSData>) -> NSData { get set }
    subscript(key: DefaultsKey<NSDate?>) -> NSDate? { get set }
    subscript(key: DefaultsKey<NSURL?>) -> NSURL? { get set }
    subscript(key: DefaultsKey<[String: AnyObject]?>) -> [String: AnyObject]? { get set }
    subscript(key: DefaultsKey<[String: AnyObject]>) -> [String: AnyObject] { get set }
    subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? { get set }
    subscript(key: DefaultsKey<NSDictionary>) -> NSDictionary { get set }
    subscript(key: DefaultsKey<[String]>) -> [String] { get set }

    func get<T: UserDefaultsDecodable>(key: DefaultsKey<T>) -> T?
    func set<T: UserDefaultsDecodable>(key: DefaultsKey<T>, value: T?)
}
