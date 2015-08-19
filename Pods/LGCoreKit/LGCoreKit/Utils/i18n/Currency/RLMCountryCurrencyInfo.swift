//
//  RLMCountryCurrencyInfo.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import RealmSwift

public class RLMCountryCurrencyInfo: Object, CountryCurrencyInfo, Printable {
    dynamic var id = 0
    
    // MARK: - CountryCurrencyInfo
    dynamic public var countryCodeAlpha2 = ""   // ISO 3166-1 alpha-2
    dynamic public var countryCodeAlpha3 = ""   // ISO 3166-1 alpha-3
    dynamic public var currencyCode = ""        // ISO 4217
    dynamic public var defaultLocale = ""
    dynamic public var currencySymbol = ""
    
    public var locale: NSLocale? {
        return NSLocale(localeIdentifier: self.defaultLocale)
    }
    
    // MARK: - Object
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Printable
    
    public override var description: String {
        return "countryCodeAlpha2: \(countryCodeAlpha2); countryCodeAlpha3: \(countryCodeAlpha3); currencyCode: \(currencyCode); defaultLocale: \(defaultLocale); currencySymbol: \(currencySymbol)"
    }
}
