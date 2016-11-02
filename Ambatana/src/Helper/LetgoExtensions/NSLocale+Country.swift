//
//  NSLocale+Country.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension NSLocale {
    var lg_countryCode: String {
        if #available(iOS 10.0, *) {
            return (countryCode ?? "").lowercaseString
        } else {
            return (objectForKey(NSLocaleCountryCode) as? String ?? "").lowercaseString
        }
    }
}
