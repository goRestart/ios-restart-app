//
//  RLMCountryInfoDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/10/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import RealmSwift

public class RLMCountryInfoDAO: CountryInfoDAO {
    
    var realm: Realm!
    
    public init?() {
        let dbFileName = "country_info-v1"
        let oldDBFilenames = ["country_currency_info, country_currency_info-v2"]
        let dbExt = "realm"
        
        let fm = NSFileManager.defaultManager()
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
        
        // Erase old DBs
        for oldDBFilename in oldDBFilenames {
            let dbCachePath = cachePath.stringByAppendingString("/\(oldDBFilename).\(dbExt)")
            if fm.fileExistsAtPath(dbCachePath) {
                do {
                    try fm.removeItemAtPath(dbCachePath)
                } catch _ {
                }
            }
        }
        
        // If the new db does not exist copy it into library caches
        let dbBundlePath = NSBundle.LGCoreKitBundle().pathForResource(dbFileName, ofType: dbExt)!
        let dbCachePath = cachePath.stringByAppendingString("/\(dbFileName).\(dbExt)")

        if !fm.fileExistsAtPath(dbCachePath) {
            do {
                try fm.copyItemAtPath(dbBundlePath, toPath: dbCachePath)
            } catch _ {
            }
        }
        
        do {
            try realm = Realm(path: dbCachePath)
        } catch _ {
            return nil
        }
        
        //        // Export to CSV
        //        var countryCurrencyInfos = realm.objects(RLMCountryCurrencyInfo)
        //        for countryCurrencyInfo in countryCurrencyInfos {
        //            let locale = countryCurrencyInfo.locale
        //            let currencyFormatter = NSNumberFormatter()
        //            currencyFormatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        //            currencyFormatter.locale = locale
        //            currencyFormatter.maximumFractionDigits = 0
        //            currencyFormatter.currencySymbol = countryCurrencyInfo.currencySymbol
        //
        //            let one = currencyFormatter.stringFromNumber(1)!
        //            let ten = currencyFormatter.stringFromNumber(10)!
        //            let hundred = currencyFormatter.stringFromNumber(100)!
        //            let thousand = currencyFormatter.stringFromNumber(1000)!
        //            let million = currencyFormatter.stringFromNumber(1000000)!
        //
        //            println("\(countryCurrencyInfo.countryCodeAlpha2);\(countryCurrencyInfo.countryCodeAlpha3);\(countryCurrencyInfo.currencyCode);\(countryCurrencyInfo.currencySymbol);\(countryCurrencyInfo.defaultLocale);\(one);\(ten);\(hundred);\(thousand);\(million)")
        //        }
        //        println("")
    }
    
    // MARK: - CountryCurrencyInfoDAO
    
    public func fetchCountryInfoWithCurrencyCode(currencyCode: String) -> CountryInfo? {
        let predicate = NSPredicate(format: "currencyCode == %@", currencyCode)
        let countryCurrencyInfos = realm.objects(RLMCountryInfo).filter(predicate)
        return countryCurrencyInfos.first
    }
    
    public func fetchCountryInfoWithCountryCode(countryCode: String) -> CountryInfo? {
        let predicate = NSPredicate(format: "countryCode == %@", countryCode, countryCode)
        let countryCurrencyInfos = realm.objects(RLMCountryInfo).filter(predicate)
        return countryCurrencyInfos.first
    }
}
