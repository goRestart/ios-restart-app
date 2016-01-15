//
//  NSLocale+LG.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 14/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

extension NSLocale {

    /**
    Return a String of the form yy-XX being yy the current language of the Device and
    XX being the current Country code. ex: en-US or es-ES

    - returns: Locale Identifier like en-US
    */
    static func localeIdString() -> String {
        let language = currentLocale().objectForKey(NSLocaleLanguageCode) as? String ?? "en"
        let countryCode = currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? "US"
        return language + "-" + countryCode
    }
}
