//
//  Keychainable.swift
//  LGCoreKit
//
//  Created by Dídac on 23/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import KeychainSwift

protocol Keychainable {
    func set(_ value: String, forKey key: String, withAccess access: KeychainSwiftAccessOptions?) -> Bool
    func get(_ key: String) -> String?
    func delete(_ key: String) -> Bool
}

extension KeychainSwift: Keychainable {}
