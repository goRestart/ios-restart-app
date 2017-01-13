//
//  CountryInfo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol CountryInfo {
    var countryCode: String { get }         // ISO 3166-1 alpha-2
    var locale: Locale? { get }
    var currencyCode: String { get }        // ISO 4217
    var currencySymbol: String { get }
    var capital: String { get }
    var coordinate: CLLocationCoordinate2D? { get }
}
