//
//  Unwrappable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

/**
Unwraps an optional.
*/
protocol Unwrappable {
    func unwrap() -> AnyObject?
}

/**
Unwraps a `Dictionary<String: Unwrappable>`.
- parameter dictionary: A dictionary.
- returns: The unwrapped dictionary.
*/
func unwrap(dictionary: [String: Unwrappable]) -> [String: AnyObject] {
    var params: [String: AnyObject] = [:]
    for (key, value) in dictionary {
        if let myOptional = value.unwrap() {
            params[key] = myOptional
        }
    }
    return params
}
