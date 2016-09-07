//
//  UserDefaultsDecodable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

public protocol UserDefaultsDecodable {
    static func decode(dictionary: [String: AnyObject]) -> Self?
    func encode() -> [String: AnyObject]
}
