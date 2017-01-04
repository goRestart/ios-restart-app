//
//  NSUserDefaults+KeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

extension UserDefaults: KeyValueStorageable {
    func get<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>) -> T? {
        guard let dict = dictionary(forKey: key._key) else { return nil }
        return T.decode(dict)
    }
    func set<T: UserDefaultsDecodable>(_ key: DefaultsKey<T>, value: T?) {
        let object = value?.encode()
        set(object, forKey: key._key)
    }
}
