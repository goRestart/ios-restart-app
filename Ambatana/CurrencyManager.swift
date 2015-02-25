//
//  CurrencyManager.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 24/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

// private singleton instance
private let _singletonInstance = CurrencyManager()

struct AmbatanaCurrency {
    var currencyCode: String
    var currencyName: String
    var iso4217Code: String
    var country: String
    var countryCode: String
    var symbolPosition: String
    
    // returns a properly formatted price/currency string for a given price given the current user locale, which may not be the same as the currency's native representation.
    func inferFormattedCurrency(price: Double, decimals: Int = 0) -> String {
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.currencyCode = self.iso4217Code
        currencyFormatter.maximumFractionDigits = decimals
        currencyFormatter.locale = NSLocale.currentLocale()
        return currencyFormatter.stringFromNumber(price) ?? "\(currencyCode)\(price)"
    }
    
    // returns a formated price/currency with a give position for the currency symbol
    func formattedCurrency(price: Double, decimals: Int = 0) -> String {
        if symbolPosition == "left" {
            return "\(self.currencyCode)\(Int(price))"
        } else if symbolPosition == "right" {
            return "\(Int(price))\(self.currencyCode)"
        } else { // fallback to best representation given the currency symbol and current locale
            return self.inferFormattedCurrency(price, decimals: decimals)
        }
    }
    
    func toString() -> String {
        return "\(currencyName) (\(currencyCode)): ISO4217 = \(iso4217Code), Country = \(country), Country code = \(countryCode), Symbol position: \(symbolPosition)";
    }
}

/**
 * The CurrencyManager class is in charge of managing all currencies handled by the application. It tries to download and validate the currencies from the backend upon 
 * initialization, and uses a fallback static set of currencies meanwhile.
 * CurrencyManager uses the Singleton design pattern, so all operations on it should be accessed by means of the sharedInstance() method.
 */
class CurrencyManager: NSObject {
    // data
    var currencies: [AmbatanaCurrency]?
    
    let defaultCurrency = AmbatanaCurrency(currencyCode: "$", currencyName: "United States dollar", iso4217Code: "USD", country: "United States of America", countryCode: "US", symbolPosition: "left")
    
    lazy var fallbackCurrencies: [AmbatanaCurrency] = {
        let usd = AmbatanaCurrency(currencyCode: "$", currencyName: "United States dollar", iso4217Code: "USD", country: "United States of America", countryCode: "US", symbolPosition: "left")
        let eur = AmbatanaCurrency(currencyCode: "€", currencyName: "European euro", iso4217Code: "EUR", country: "Europe", countryCode: "EU", symbolPosition: "right")
        let gbp = AmbatanaCurrency(currencyCode: "£", currencyName: "British pound", iso4217Code: "GBP", country: "United Kingdom", countryCode: "UK", symbolPosition: "left")
        let ars = AmbatanaCurrency(currencyCode: "$a", currencyName: "Argentine peso", iso4217Code: "ARS", country: "Argentina", countryCode: "AR", symbolPosition: "left")
        let brl = AmbatanaCurrency(currencyCode: "R$", currencyName: "Brazilian real", iso4217Code: "BRL", country: "Brazil", countryCode: "BR", symbolPosition: "left")
        return [usd, eur, gbp, ars, brl]
    }()
    
    /** Shared instance */
    class var sharedInstance: CurrencyManager {
        return _singletonInstance
    }
    
    // perform a PFQuery to get the currencies.
    func refreshCurrenciesFromBackend() {
        let pfquery = PFQuery(className: "Currencies")
        pfquery.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            println("Retrieved currencies from the backend")
            if let currencies = results as? [PFObject] {
                var retrievedCurrencies: [AmbatanaCurrency] = []
                // iterate and add valid retrieved currencies.
                for currencyObject in currencies {
                    let currencyCode = currencyObject["currency_code"] as? String
                    let currencyName = currencyObject["currency_name"] as? String
                    let iso4217Code = currencyObject["currency_iso4217"] as? String
                    let country = currencyObject["country"] as? String
                    let countryCode = currencyObject["country_code"] as? String
                    let symbolPosition = currencyObject["position"] as? String ?? "unknown"
                    if currencyCode != nil && currencyName != nil && iso4217Code != nil && country != nil && countryCode != nil {
                        retrievedCurrencies.append(AmbatanaCurrency(currencyCode: currencyCode!, currencyName: currencyName!, iso4217Code: iso4217Code!, country: country!, countryCode: countryCode!, symbolPosition: symbolPosition))
                    }
                }
                self.currencies = retrievedCurrencies
            }
        }
    }
    
    func allCurrencies() -> [AmbatanaCurrency] {
        return currencies ?? fallbackCurrencies
    }
    
    func currencyForISO4217Symbol(symbol: String) -> AmbatanaCurrency? {
        for currency in allCurrencies() {
            if currency.iso4217Code == symbol { return currency }
        }
        return nil
    }

}
