//
//  RLMCountryCurrencyInfoDAO.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import RealmSwift

public class RLMCountryCurrencyInfoDAO: CountryCurrencyInfoDAO {
 
    var realm: Realm
    
    public init() {
        let dbFileName = "country_currency_info-v2"
        let oldDBFilenames = ["country_currency_info"]
        let dbExt = "realm"

        let fm = NSFileManager.defaultManager()
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! NSString
        
        // Erase old DBs
        for oldDBFilename in oldDBFilenames {
            let dbCachePath = cachePath.stringByAppendingString("/\(oldDBFilename).\(dbExt)")
            if fm.fileExistsAtPath(dbCachePath) {
                fm.removeItemAtPath(dbCachePath, error: nil)
            }
        }
        
        // If the new db does not exist copy it into library caches
        let dbBundlePath = NSBundle.LGCoreKitBundle().pathForResource(dbFileName, ofType: dbExt)!
        let dbCachePath = cachePath.stringByAppendingString("/\(dbFileName).\(dbExt)")
        if !fm.fileExistsAtPath(dbCachePath) {
            fm.copyItemAtPath(dbBundlePath, toPath: dbCachePath, error: nil)
        }
        realm = Realm(path: dbCachePath)

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
    
    public func fetchCountryCurrencyInfoWithCurrencyCode(currencyCode: String) -> CountryCurrencyInfo? {
        let predicate = NSPredicate(format: "currencyCode == %@", currencyCode)
        var countryCurrencyInfos = realm.objects(RLMCountryCurrencyInfo).filter(predicate)
        return countryCurrencyInfos.first
    }
    
    public func fetchCountryCurrencyInfoWithCountryCode(countryCode: String) -> CountryCurrencyInfo? {
        let predicate = NSPredicate(format: "countryCodeAlpha2 == %@ OR countryCodeAlpha3 == %@", countryCode, countryCode)
        var countryCurrencyInfos = realm.objects(RLMCountryCurrencyInfo).filter(predicate)
        return countryCurrencyInfos.first
    }
}