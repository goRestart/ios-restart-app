//
//  MyUser.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

public protocol MyUser: User {
    var email: String? { get }
    var location: LGLocation? { get }
}

public extension MyUser {
    var coordinates: LGLocationCoordinates2D? {
        guard let coordinates = location?.coordinate else { return nil }
        return LGLocationCoordinates2D(coordinates: coordinates)
    }
    var isDummy: Bool {
        let dummyRange = (email ?? "").rangeOfString("usercontent")
        if let isDummyRange = dummyRange where isDummyRange.startIndex == (email ?? "").startIndex {
            return true
        }
        else {
            return false
        }
    }
}
