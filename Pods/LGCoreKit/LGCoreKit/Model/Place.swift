//
//  Place.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


@objc public class Place {

    public var name : String?
    public var postalAddress : PostalAddress?
    public var location : LGLocationCoordinates2D?
    
    public var country : String?
    
    public var placeResumedData : String?
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
}