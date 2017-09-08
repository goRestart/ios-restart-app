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
    
    public var placeId: String?
    public var shouldRetrieveDetails: Bool?
}

public extension Place {

    public init(postalAddress: PostalAddress?, location: LGLocationCoordinates2D?) {
        self.postalAddress = postalAddress
        self.location = location
    }
    
    public init(placeId: String?, placeResumedData: String?) {
        self.placeId = placeId
        self.placeResumedData = placeResumedData
        shouldRetrieveDetails = true
    }

    public static func newPlace() -> Place {
        return Place()
    }
}
