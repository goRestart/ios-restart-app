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

        guard let plistPath = Bundle.LGCoreKitBundle().url(forResource: fileName, withExtension: fileExtension) else { return }
        guard let data = try? Data(contentsOf: plistPath) else { return }
        guard let plistInfo = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [[String: Any]],
            let infosRaw = plistInfo else { return }
        for dictionary in infosRaw {
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
