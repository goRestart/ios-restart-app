//
//  LetGoIPGeoLocation.swift
//  LetGo
//
//  Created by Nacho on 15/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import UIKit

/**
 * This class represents a geolocation reverse lookup based on IP address.
 */
class LetGoIPGeoLocation: NSObject, Printable {
    // data
    var countryCode: String!
    var countryCodeAlternative: String?
    var countryName: String!
    var continentCode: String!
    var location: CLLocationCoordinate2D!
    
    init(countryCode: String, countryCodeAlternative: String?, countryName: String, continentCode: String, location: CLLocationCoordinate2D) {
        self.countryCode = countryCode
        self.countryCodeAlternative = countryCodeAlternative
        self.countryName = countryName
        self.continentCode = continentCode
        self.location = location
    }
    
    init?(valuesFromDictionary dictionary: [String: AnyObject]) {
        super.init()
        if let countryCode = dictionary[kLetGoRestAPIParameterCountryCode] as? String { self.countryCode = countryCode  }
        if let countryCodeAlt = dictionary[kLetGoRestAPIParameterCountryCodeAlt] as? String { self.countryCodeAlternative = countryCodeAlt }
        if self.countryCode == nil && self.countryCodeAlternative == nil { return nil } // we need at least one country code.
        if let countryName = dictionary[kLetGoRestAPIParameterCountryName] as? String { self.countryName = countryName } else { return nil }
        if let continentCode = dictionary[kLetGoRestAPIParameterContinentCode] as? String { self.continentCode = continentCode } else { return nil }
        if let latitude = dictionary[kLetGoRestAPIParameterLatitude]?.floatValue, longitude = dictionary[kLetGoRestAPIParameterLongitude]?.floatValue {
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
            if CLLocationCoordinate2DIsValid(location) { self.location = location } else { return nil }
        } else { return nil }
    }
    
    override var description: String { return "LetGoIPGeoLocation: \ncountry code: \(countryCode), \nalternative country code: \(countryCodeAlternative)\ncountry name: \(countryName)\ncontinent code: \(continentCode)\nlocation: \(location.latitude),\(location.longitude)" }

}
