//
//  NSLocale+Country.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension NSLocale {
    var systemCountryCode: String {
        if #available(iOS 10.0, *) {
            return NSLocale.currentLocale().countryCode ?? ""
        } else {
            return NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? ""
        }
    }
}
