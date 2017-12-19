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
    private var locale: Locale
    private var countryInfoDAO: CountryInfoDAO

    
    // MARK: - Lifecycle

    public init(locale: Locale, countryInfoDAO: CountryInfoDAO) {

        self.locale = locale
        self.countryInfoDAO = countryInfoDAO
    }

    
    // MARK: - Public methods

    public var regionCoordinate: CLLocationCoordinate2D {
        // stated in: http://stackoverflow.com/a/39769250/1666070 regionCode matches countryCode on NSLocale
        if let countryCode = locale.regionCode,
           let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode.uppercased()),
           let coordinate = countryInfo.coordinate {
            return coordinate
        }
        return LGCoreKitConstants.defaultCoordinate
    }

    public func countryInfoForCountryCode(_ countryCode: String) -> CountryInfo? {
        return countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode)
    }
}
