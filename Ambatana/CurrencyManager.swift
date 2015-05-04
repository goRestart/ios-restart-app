//
//  CurrencyManager.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 24/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit
import Parse

// private singleton instance
private let _singletonInstance = CurrencyManager()

/**
 * The CurrencyManager class is in charge of managing all currencies handled by the application. It tries to download and validate the currencies from the backend upon 
 * initialization, and uses a fallback static set of currencies meanwhile.
 * CurrencyManager uses the Singleton design pattern, so all operations on it should be accessed by means of the sharedInstance() method.
 */
class CurrencyManager: NSObject {
    // data
    var currencies: [LetGoCurrency]?
    
    let defaultCurrency = LetGoCurrency(currencyCode: "$", currencyName: "United States dollar", iso4217Code: "USD", country: "United States of America", countryCode: "US", symbolPosition: "left")
    
    lazy var fallbackCurrencies: [LetGoCurrency] = {
        let usd = LetGoCurrency(currencyCode: "$", currencyName: "United States dollar", iso4217Code: "USD", country: "United States of America", countryCode: "US", symbolPosition: "left")
        let eur = LetGoCurrency(currencyCode: "€", currencyName: "European euro", iso4217Code: "EUR", country: "Europe", countryCode: "EU", symbolPosition: "right")
        let gbp = LetGoCurrency(currencyCode: "£", currencyName: "British pound", iso4217Code: "GBP", country: "United Kingdom", countryCode: "UK", symbolPosition: "left")
        let ars = LetGoCurrency(currencyCode: "$a", currencyName: "Argentine peso", iso4217Code: "ARS", country: "Argentina", countryCode: "AR", symbolPosition: "left")
        let brl = LetGoCurrency(currencyCode: "R$", currencyName: "Brazilian real", iso4217Code: "BRL", country: "Brazil", countryCode: "BR", symbolPosition: "left")
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
            //println("Retrieved currencies from the backend")
            if let currencies = results as? [PFObject] {
                var retrievedCurrencies: [LetGoCurrency] = []
                // iterate and add valid retrieved currencies.
                for currencyObject in currencies {
                    let currencyCode = currencyObject["currency_code"] as? String
                    let currencyName = currencyObject["currency_name"] as? String
                    let iso4217Code = currencyObject["currency_iso4217"] as? String
                    let country = currencyObject["country"] as? String
                    let countryCode = currencyObject["country_code"] as? String
                    let symbolPosition = currencyObject["position"] as? String ?? "unknown"
                    if currencyCode != nil && currencyName != nil && iso4217Code != nil && country != nil && countryCode != nil {
                        retrievedCurrencies.append(LetGoCurrency(currencyCode: currencyCode!, currencyName: currencyName!, iso4217Code: iso4217Code!, country: country!, countryCode: countryCode!, symbolPosition: symbolPosition))
                    }
                }
                self.currencies = retrievedCurrencies
            }
        }
    }
    
    func allCurrencies() -> [LetGoCurrency] {
        return currencies ?? fallbackCurrencies
    }
    
    func currencyForISO4217Symbol(symbol: String) -> LetGoCurrency? {
        for currency in allCurrencies() {
            if currency.iso4217Code == symbol { return currency }
        }
        return nil
    }

}
