//
//  GlobalFunctions.swift
//  LGCoreKit
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

// Equatable for optional arrays
// Ref: http://stackoverflow.com/questions/29478665/comparing-optional-arrays
func ==<T: Equatable>(lhs: [T]?, rhs: [T]?) -> Bool {
    switch (lhs,rhs) {
    case (.Some(let lhs), .Some(let rhs)):
        return lhs == rhs
    case (.None, .None):
        return true
    default:
        return false
    }
}

// Comparable enums
// Ref: http://stackoverflow.com/questions/27869397/swift-enumeration-order-and-comparison
public func <<T: RawRepresentable where T.RawValue: Comparable>(a: T, b: T) -> Bool {
    return a.rawValue < b.rawValue
}