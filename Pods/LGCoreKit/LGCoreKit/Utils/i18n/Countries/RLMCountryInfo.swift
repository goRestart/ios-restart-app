//
//  RLMCountryInfo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import RealmSwift

public class RLMCountryInfo: Object, CountryInfo {
    dynamic var id = 0
    dynamic public var countryCode = ""         // ISO 3166-1 alpha-2
    dynamic public var defaultLocale = ""
    dynamic public var currencyCode = ""        // ISO 4217
    dynamic public var currencySymbol = ""
    dynamic public var capital = ""
    dynamic public var lat: Double = Double.infinity
    dynamic public var lon: Double = Double.infinity
    
    public var locale: NSLocale? {
        return NSLocale(localeIdentifier: defaultLocale)
    }
    
    public var coordinate: CLLocationCoordinate2D? {
        if lat != Double.infinity && lon != Double.infinity {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    public override static func primaryKey() -> String? {
        return "id"
    }
}

