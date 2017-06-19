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
    var localeIdentifier: String? { get }
}

public extension MyUser {
    var coordinates: LGLocationCoordinates2D? {
        guard let coordinates = location?.coordinate else { return nil }
        return LGLocationCoordinates2D(coordinates: coordinates)
    }
    var isDummy: Bool {
        let dummyRange = (email ?? "").range(of: "usercontent")
        if let isDummyRange = dummyRange, isDummyRange.lowerBound == (email ?? "").startIndex {
            return true
        }
        else {
            return false
        }
    }
    var postalAddress: PostalAddress {
        return location?.postalAddress ?? PostalAddress.emptyAddress()
    }
}
