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
    private let states = ["Alaska", "Alabama", "Arkansas", "American Samoa", "Arizona", "California", "Colorado",
                          "Connecticut", "District of Columbia", "Delaware", "Florida", "Georgia", "Guam", "Hawaii", "Iowa",
                          "Idaho", "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland",
                          "Maine", "Michigan", "Minnesota", "Missouri", "Mississippi", "Montana", "North Carolina",
                          "North Dakota", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "Nevada", "New York",
                          "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Puerto Rico", "Rhode Island", "South Carolina",
                          "South Dakota", "Tennessee", "Texas", "Utah", "Virginia", "Virgin Islands", "Vermont", "Washington",
                          "Wisconsin", "West Virginia", "Wyoming"]

    
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

    public func fullCountryInfoList() -> [CountryInfo] {
        return countryInfoDAO.fetchFullCountryInfoList()
    }

    public func usStatesList() -> [String] {
        return states
    }
}
