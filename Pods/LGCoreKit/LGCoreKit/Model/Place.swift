//
//  Place.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public struct Place {

    public var name : String?
    public var postalAddress : PostalAddress?
    public var location : LGLocationCoordinates2D?

    public var placeResumedData : String?
}

public extension Place {

    public init(postalAddress: PostalAddress?, location: LGLocationCoordinates2D?){
        self.postalAddress = postalAddress
        self.location = location
    }

    public static func newPlace() -> Place{
        return Place()
    }
}
