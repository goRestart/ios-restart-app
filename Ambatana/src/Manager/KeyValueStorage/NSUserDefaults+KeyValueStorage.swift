//
//  NSUserDefaults+KeyValueStorage.swift
//  LetGo
//
//  Created by Albert Hernández López on 09/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import SwiftyUserDefaults

extension NSUserDefaults: KeyValueStorageable {
    func get<T: UserDefaultsDecodable>(key: DefaultsKey<T>) -> T? {
        guard let dict = dictionaryForKey(key._key) else { return nil }
        return T.decode(dict)
    }
    func set<T: UserDefaultsDecodable>(key: DefaultsKey<T>, value: T?) {
        let object = value?.encode()
        setObject(object, forKey: key._key)
    }
}
