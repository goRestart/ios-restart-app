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
    Returns a String of the form yy-XX being yy the language and XX being the current country code. 
     ex: en-US or es-ES

    - returns: Locale Identifier like en-US
    */
    func localeIdString() -> String {
        let language = objectForKey(NSLocaleLanguageCode) as? String ?? NSLocale.defaultLang
        let countryCode = objectForKey(NSLocaleCountryCode) as? String ?? NSLocale.defaultCountry
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
