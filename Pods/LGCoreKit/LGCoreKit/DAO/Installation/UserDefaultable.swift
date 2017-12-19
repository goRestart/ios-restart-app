//
//  UserDefaultable.swift
//  LGCoreKit
//
//  Created by Dídac on 26/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

protocol UserDefaultable {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    func object(forKey defaultName: String) -> Any?
    func removeObject(forKey defaultName: String)
    func reset()
}

extension UserDefaults: UserDefaultable {
    func reset() {}
}
