//
//  CountryHelper.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public class CountryHelper {

    // iVars
    private var locale: NSLocale
    private var countryInfoDAO: CountryInfoDAO

    
    // MARK: - Lifecycle

    public init(locale: NSLocale, countryInfoDAO: CountryInfoDAO) {

        self.locale = locale
        self.countryInfoDAO = countryInfoDAO
    }

    
    // MARK: - Public methods

    public var regionCoordinate: CLLocationCoordinate2D {
        if let countryCode = locale.objectForKey(NSLocaleCountryCode) as? String,
           let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode.uppercaseString),
           let coordinate = countryInfo.coordinate {
            return coordinate
        }
        return LGCoreKitConstants.defaultCoordinate
    }

    public func countryInfoForCountryCode(countryCode: String) -> CountryInfo? {
        return countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode)
    }
}
