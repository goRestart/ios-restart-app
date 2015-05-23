//
//  CurrencyHelper.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class CurrencyHelper {
    
    // Constants
    private static let defaultCurrency = Currency(code: "USD", symbol: "$")
    
    // Singleton
    public static let sharedInstance: CurrencyHelper = CurrencyHelper()
    
    // iVars
    public private(set) var locale: NSLocale {
        didSet {
            currencyFormatter = CurrencyHelper.currencyFormatterWithLocale(locale)
        }
    }
    private var currencyFormatter: NSNumberFormatter
    private var currencyCodeToFormatter: [String: NSNumberFormatter]
    private var countryCurrencyInfoDAO: CountryCurrencyInfoDAO
    
    // MARK: - Lifecycle
    
    public init(locale: NSLocale = NSLocale.autoupdatingCurrentLocale(), countryCurrencyInfoDAO: CountryCurrencyInfoDAO = RLMCountryCurrencyInfoDAO()) {
        self.locale = locale
        self.currencyFormatter = NSNumberFormatter()
        self.currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        self.currencyFormatter.locale = locale
        self.currencyFormatter.maximumFractionDigits = 0
        self.currencyCodeToFormatter = [:]
        self.countryCurrencyInfoDAO = countryCurrencyInfoDAO
    }
    
    // MARK: - Public methods

    public var currentCurrency: Currency {
        if let code = locale.objectForKey(NSLocaleCurrencyCode) as? String,
            let symbol = locale.objectForKey(NSLocaleCurrencySymbol) as? String {
                return Currency(code: code, symbol: symbol)
        }
        return CurrencyHelper.defaultCurrency
    }
    
    public func setCountryCode(countryCode: String) {
        // If the country is found in the DB and has a locale, update locale
        if let countryCurrencyInfo = countryCurrencyInfoDAO.fetchCountryCurrencyInfoWithCountryCode(countryCode), let countryLocale = countryCurrencyInfo.locale {
            locale = countryLocale
        }
    }
    
    public func formattedAmount(amount: NSNumber) -> String? {
        return currencyFormatter.stringFromNumber(amount)
    }
    
    public func formattedAmountWithCurrencyCode(currencyCode: String, amount: NSNumber) -> String? {
        // If we find the formatter in the dict then just use it
        if let formatter = currencyCodeToFormatter[currencyCode] {
            return formatter.stringFromNumber(amount)
        }
        
        // Otherwise, look for it in the DB
        let currencyLocale: NSLocale
        if let countryCurrencyInfo = countryCurrencyInfoDAO.fetchCountryCurrencyInfoWithCurrencyCode(currencyCode) {
            currencyLocale = countryCurrencyInfo.locale ?? locale
        }
        else {
            // If not found it's formatted with the current locale
            currencyLocale = locale
        }
        
        // Add it to the dict
        let formatter = CurrencyHelper.currencyFormatterWithLocale(currencyLocale)
        currencyCodeToFormatter[currencyCode] = formatter
        
        return formatter.stringFromNumber(amount)
    }
    
    // MARK: - Private methods
    
    private static func currencyFormatterWithLocale(locale: NSLocale) -> NSNumberFormatter {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        currencyFormatter.locale = locale
        currencyFormatter.maximumFractionDigits = 0
        return currencyFormatter
    }
}