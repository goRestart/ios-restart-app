//
//  LGIPLookupLocationResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGIPLookupLocationResponse: IPLookupLocationResponse {
    
    // iVars
    public let coordinates: LGLocationCoordinates2D
    
}

extension LGIPLookupLocationResponse : ResponseObjectSerializable {
    // Constant
    private static let latitudeJSONKey = "latitude"
    private static let longitudeJSONKey = "longitude"
    
    // MARK: - ResponseObjectSerializable
    
    //  {
    //      "country_code": "US",
    //      "country_code3": "US",
    //      "country_name": "United States",
    //      "region": "California",
    //      "city": "Mountain View",
    //      "zipcode": "94040",
    //      "latitude": 37.386,
    //      "longitude": -122.0838,
    //      "area_code": false,
    //      "metro_code": false,
    //      "continent_code": "NA"
    //  }
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theLocation : LGLocationCoordinates2D = LGArgo.jsonToCoordinates(JSON.parse(representation), latKey: "latitude", lonKey: "longitude").value else {
            return nil
        }
        self.coordinates = theLocation
    }
}