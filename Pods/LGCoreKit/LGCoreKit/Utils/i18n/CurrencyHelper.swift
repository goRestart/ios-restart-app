//
//  CurrencyHelper.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class CurrencyHelper {

    // iVars
    private let defaultLocale: NSLocale

    private var currencyCodeToFormatter: [String: NSNumberFormatter]
    private var countryCodeToFormatter: [String: NSNumberFormatter]
    private var countryInfoDAO: CountryInfoDAO

    // MARK: - Lifecycle

    public init(countryInfoDAO: CountryInfoDAO, defaultLocale: NSLocale) {

        self.currencyCodeToFormatter = [:]
        self.countryCodeToFormatter = [:]

        self.countryInfoDAO = countryInfoDAO
        self.defaultLocale = defaultLocale
    }

    // MARK: - Public methods

    public func selectableCurrenciesForCountryCode(countryCode: String) -> [Currency] {
        var currencies: [Currency] = []
        let currency = currencyWithCountryCode(countryCode)
        currencies.append(currency)
        if !currencies.contains(LGCoreKitConstants.usdCurrency) {
            currencies.append(LGCoreKitConstants.usdCurrency)
        }
        if !currencies.contains(LGCoreKitConstants.eurCurrency) {
            currencies.append(LGCoreKitConstants.eurCurrency)
        }
        return currencies
    }

    /**
        Returns a formatted string for the given amount with the given currency code.

        - returns: A currency formatted string.
    */
    public func formattedAmountWithCurrencyCode(currencyCode: String, amount: NSNumber) -> String {
        return formatterWithCurrencyCode(currencyCode).stringFromNumber(amount) ?? LGCoreKitConstants.defaultCurrency.code
    }

    /**
     Returns a formatted string for the given amount with the given country code.

     - returns: A currency formatted string.
     */
    public func formattedAmountWithCountryCode(countryCode: String, amount: NSNumber) -> String {
        return formatterWithCountryCode(countryCode).stringFromNumber(amount) ?? LGCoreKitConstants.defaultCurrency.code
    }

    /**
        Returns the currency symbol for the given currency code.

        - returns: A currency formatted string.
    */
    public func currencySymbolWithCurrencyCode(currencyCode: String) -> String {
        return formatterWithCurrencyCode(currencyCode).currencySymbol ?? LGCoreKitConstants.defaultCurrency.symbol
    }

    /**
     Returns the currency symbol for the given country code.

     - returns: A currency formatted string.
     */
    public func currencySymbolWithCountryCode(countryCode: String) -> String {
        return formatterWithCountryCode(countryCode).currencySymbol ?? LGCoreKitConstants.defaultCurrency.symbol
    }

    /**
        Returns the currency for the given currency code.

        - returns: A currency.
    */
    public func currencyWithCurrencyCode(code: String) -> Currency {
        let symbol = self.currencySymbolWithCurrencyCode(code)
        return Currency(code: code, symbol: symbol)
    }

    /**
     Returns the currency for the given country code.

     - returns: A currency.
     */
    public func currencyWithCountryCode(code: String) -> Currency {
        guard let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(code) else {
            return LGCoreKitConstants.defaultCurrency
        }
        return Currency(code: countryInfo.currencyCode, symbol: countryInfo.currencySymbol)
    }

    // MARK: - Private methods

    private func formatterWithCurrencyCode(currencyCode: String) -> NSNumberFormatter {
        if let formatter = currencyCodeToFormatter[currencyCode] {
            return formatter
        }

        let currencyLocale: NSLocale
        let currencySymbol: String?
        if let countryInfo = countryInfoDAO.fetchCountryInfoWithCurrencyCode(currencyCode), locale = countryInfo.locale {
            currencyLocale = locale
            currencySymbol = countryInfo.currencySymbol
        }
        else {
            currencyLocale = defaultLocale
            currencySymbol = nil
        }

        let formatter = CurrencyHelper.currencyFormatterWithLocale(currencyLocale, currencySymbol: currencySymbol)
        currencyCodeToFormatter[currencyCode] = formatter

        return formatter
    }

    private func formatterWithCountryCode(countryCode: String) -> NSNumberFormatter {
        if let formatter = countryCodeToFormatter[countryCode] {
            return formatter
        }

        let currencyLocale: NSLocale
        let currencySymbol: String?
        if let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode), locale = countryInfo.locale {
            currencyLocale = locale
            currencySymbol = countryInfo.currencySymbol
        }
        else {
            currencyLocale = defaultLocale
            currencySymbol = nil
        }

        let formatter = CurrencyHelper.currencyFormatterWithLocale(currencyLocale, currencySymbol: currencySymbol)
        countryCodeToFormatter[countryCode] = formatter

        return formatter
    }

    private static func currencyFormatterWithLocale(locale: NSLocale, currencySymbol: String?) -> NSNumberFormatter {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        currencyFormatter.locale = locale
        currencyFormatter.minimumFractionDigits = 0
        if let actualCurrencySymbol = currencySymbol {
            currencyFormatter.currencySymbol = actualCurrencySymbol
        }
        return currencyFormatter
    }
}
