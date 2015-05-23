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
        let dbFileName = "country_currency_info"
        let dbExt = "realm"
        let dbBundlePath = NSBundle.LGCoreKitBundle().pathForResource(dbFileName, ofType: dbExt)!
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! NSString
        let dbCachePath = cachePath.stringByAppendingString("/\(dbFileName).\(dbExt)")
        
        // If the db does not exist copy it into library caches
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath(dbCachePath) {
            fm.copyItemAtPath(dbBundlePath, toPath: dbCachePath, error: nil)
        }
        realm = Realm(path: dbCachePath)
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