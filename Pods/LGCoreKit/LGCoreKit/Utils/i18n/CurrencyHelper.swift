//
//  CurrencyHelper.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class CurrencyHelper {

    // iVars
    private let defaultLocale: Locale

    private var currencyCodeToFormatter: [String: NumberFormatter]
    private var countryCodeToFormatter: [String: NumberFormatter]
    private var countryInfoDAO: CountryInfoDAO

    // MARK: - Lifecycle

    public init(countryInfoDAO: CountryInfoDAO, defaultLocale: Locale) {

        self.currencyCodeToFormatter = [:]
        self.countryCodeToFormatter = [:]

        self.countryInfoDAO = countryInfoDAO
        self.defaultLocale = defaultLocale
    }

    // MARK: - Public methods

    public func selectableCurrenciesForCountryCode(_ countryCode: String) -> [Currency] {
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
    public func formattedAmountWithCurrencyCode(_ currencyCode: String, amount: Double) -> String {
        return formatterWithCurrencyCode(currencyCode).string(from: NSNumber(value: amount)) ?? LGCoreKitConstants.defaultCurrency.code
    }

    /**
     Returns a formatted string for the given amount with the given country code.

     - returns: A currency formatted string.
     */
    public func formattedAmountWithCountryCode(_ countryCode: String, amount: Double) -> String {
        return formatterWithCountryCode(countryCode).string(from: NSNumber(value: amount)) ?? LGCoreKitConstants.defaultCurrency.code
    }

    /**
        Returns the currency symbol for the given currency code.

        - returns: A currency formatted string.
    */
    public func currencySymbolWithCurrencyCode(_ currencyCode: String) -> String {
        return formatterWithCurrencyCode(currencyCode).currencySymbol ?? LGCoreKitConstants.defaultCurrency.symbol
    }

    /**
     Returns the currency symbol for the given country code.

     - returns: A currency formatted string.
     */
    public func currencySymbolWithCountryCode(_ countryCode: String) -> String {
        return formatterWithCountryCode(countryCode).currencySymbol ?? LGCoreKitConstants.defaultCurrency.symbol
    }

    /**
        Returns the currency for the given currency code.

        - returns: A currency.
    */
    public func currencyWithCurrencyCode(_ code: String) -> Currency {
        let symbol = self.currencySymbolWithCurrencyCode(code)
        return Currency(code: code, symbol: symbol)
    }

    /**
     Returns the currency for the given country code.

     - returns: A currency.
     */
    public func currencyWithCountryCode(_ code: String) -> Currency {
        guard let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(code) else {
            return LGCoreKitConstants.defaultCurrency
        }
        return Currency(code: countryInfo.currencyCode, symbol: countryInfo.currencySymbol)
    }

    // MARK: - Private methods

    private func formatterWithCurrencyCode(_ currencyCode: String) -> NumberFormatter {
        if let formatter = currencyCodeToFormatter[currencyCode] {
            return formatter
        }

        let currencyLocale: Locale
        let currencySymbol: String?
        if let countryInfo = countryInfoDAO.fetchCountryInfoWithCurrencyCode(currencyCode), let locale = countryInfo.locale {
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

    private func formatterWithCountryCode(_ countryCode: String) -> NumberFormatter {
        if let formatter = countryCodeToFormatter[countryCode] {
            return formatter
        }

        let currencyLocale: Locale
        let currencySymbol: String?
        if let countryInfo = countryInfoDAO.fetchCountryInfoWithCountryCode(countryCode), let locale = countryInfo.locale {
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

    private static func currencyFormatterWithLocale(_ locale: Locale, currencySymbol: String?) -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.locale = locale
        currencyFormatter.minimumFractionDigits = 0
        if let actualCurrencySymbol = currencySymbol {
            currencyFormatter.currencySymbol = actualCurrencySymbol
        }
        return currencyFormatter
    }
}
