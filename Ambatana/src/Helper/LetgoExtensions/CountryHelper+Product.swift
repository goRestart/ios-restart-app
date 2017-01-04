//
//  CountryHelper+Product.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension CountryHelper {
    func countryLanguageForProduct(_ product: Product) -> String? {
        guard let countryCode = product.postalAddress.countryCode else { return nil }
        guard let countryInfo = countryInfoForCountryCode(countryCode) else { return nil }
        guard let locale = countryInfo.locale else { return nil }
        guard let languageCode = locale.objectForKey(NSLocaleLanguageCode) as? String else { return nil }
        return languageCode
    }
}
