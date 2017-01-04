//
//  LGCountryInfo.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 09/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import CoreLocation

struct LGCountryInfo: CountryInfo {
    let id: Int
    let countryCode: String         // ISO 3166-1 alpha-2
    let defaultLocale: String
    let currencyCode: String        // ISO 4217
    let currencySymbol: String
    let capital: String
    let lat: Double
    let lon: Double

    var locale: Locale? {
        return Locale(identifier: defaultLocale)
    }

    var coordinate: CLLocationCoordinate2D? {
        if lat != Double.infinity && lon != Double.infinity {
            return CLLocationCoordinate2DMake(lat, lon)
        }
        return kCLLocationCoordinate2DInvalid
    }

    static func fromDictionary(_ dict: NSDictionary) -> LGCountryInfo? {
        guard let id = dict["id"] as? Int else { return nil }
        guard let countryCode = dict["countryCode"] as? String else { return nil }
        guard let defaultLocale = dict["defaultLocale"] as? String else { return nil }
        guard let currencyCode = dict["currencyCode"] as? String else { return nil }
        guard let currencySymbol = dict["currencySymbol"] as? String else { return nil }
        guard let capital = dict["capital"] as? String else { return nil }
        guard let lat = dict["lat"] as? Double else { return nil }
        guard let lon = dict["lon"] as? Double else { return nil }
        return LGCountryInfo(id: id, countryCode: countryCode, defaultLocale: defaultLocale, currencyCode: currencyCode,
            currencySymbol: currencySymbol, capital: capital, lat: lat, lon: lon)
    }
}
