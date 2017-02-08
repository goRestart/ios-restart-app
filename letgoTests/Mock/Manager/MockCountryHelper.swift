//
//  MockCountryHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension CountryHelper {
    static func mock(locale: Locale = Locale.autoupdatingCurrent, infoDAO: MockCountryInfoDAO = MockCountryInfoDAO()) -> CountryHelper {
        return CountryHelper(locale: locale, countryInfoDAO: infoDAO)
    }
}

class MockCountryInfoDAO: CountryInfoDAO {

    var countryInfo: CountryInfo?

    func fetchCountryInfoWithCurrencyCode(_ currencyCode: String) -> CountryInfo? {
        return countryInfo
    }
    func fetchCountryInfoWithCountryCode(_ countryCode: String) -> CountryInfo? {
        return countryInfo
    }
}
