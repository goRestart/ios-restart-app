//
//  CountryInfoPlistDAO.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 09/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


class CountryInfoPlistDAO: CountryInfoDAO {
    private var infosByCountryCode: [String : CountryInfo] = [:]
    private var infosByCurrencyCode: [String : CountryInfo] = [:]

    init() {
        let fileName = "CountryInfo-v1"
        let fileExtension = "plist"
        let plistPath = Bundle.LGCoreKitBundle().path(forResource: fileName, ofType: fileExtension)!

        guard let infosRaw = NSArray(contentsOfFile: plistPath) else { return }

        for dictionary in infosRaw {
            guard let dictionary = dictionary as? NSDictionary else { continue }
            guard let countryInfo = LGCountryInfo.fromDictionary(dictionary) else { continue }
            infosByCountryCode[countryInfo.countryCode] = countryInfo
            if infosByCurrencyCode[countryInfo.currencyCode] == nil {
                //Keep the first one
                infosByCurrencyCode[countryInfo.currencyCode] = countryInfo
            }
        }
    }

    // MARK: - CountryCurrencyInfoDAO

    func fetchCountryInfoWithCurrencyCode(_ currencyCode: String) -> CountryInfo? {
        return infosByCurrencyCode[currencyCode]
    }

    func fetchCountryInfoWithCountryCode(_ countryCode: String) -> CountryInfo? {
        return infosByCountryCode[countryCode]
    }
}
