//
//  LGIPLookupLocationResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGIPLookupLocationResponse: IPLookupLocationResponse, ResponseObjectSerializable {

    // Constant
    private static let latitudeJSONKey = "latitude"
    private static let longitudeJSONKey = "longitude"
    
    // iVars
    public var coordinates: LGLocationCoordinates2D
    
    // MARK: - Lifecycle
    
    public init() {
        coordinates = LGLocationCoordinates2D(latitude: 0, longitude: 0)
    }
    
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
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        if let latitude = json[LGIPLookupLocationResponse.latitudeJSONKey].double, let longitude = json[LGIPLookupLocationResponse.longitudeJSONKey].double {
            coordinates = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        }
        else {
            return nil
        }
    }
}
