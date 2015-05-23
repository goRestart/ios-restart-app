//
//  CountryCurrencyInfo.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol CountryCurrencyInfo {
    var countryCodeAlpha2: String { get }   // ISO 3166-1 alpha-2
    var countryCodeAlpha3: String { get }   // ISO 3166-1 alpha-3
    var currencyCode: String { get }        // ISO 4217
    var locale: NSLocale? { get }
}