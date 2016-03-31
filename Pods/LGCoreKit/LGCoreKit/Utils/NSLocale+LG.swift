//
//  NSLocale+LG.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 14/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

extension NSLocale {

    private static let defaultLang = "en"
    private static let defaultCountry = "US"

    /**
    Return a String of the form yy-XX being yy the current language of the Device and
    XX being the current Country code. ex: en-US or es-ES

    - returns: Locale Identifier like en-US
    */
    static func localeIdString() -> String {
        let language = currentLocale().objectForKey(NSLocaleLanguageCode) as? String ?? NSLocale.defaultLang
        let countryCode = currentLocale().objectForKey(NSLocaleCountryCode) as? String ?? NSLocale.defaultCountry
        return language + "-" + countryCode
    }

    static func preferredLanguage() -> String {
        guard let systemLanguage = preferredLanguages().first else { return NSLocale.defaultLang }
        let components = systemLanguage.componentsSeparatedByString("-")
        // In case it's like es-ES, just take the first "es"
        guard let firstComponent = components.first else { return NSLocale.defaultLang }
        return firstComponent.lowercaseString
    }
}
