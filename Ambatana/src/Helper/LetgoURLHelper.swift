//
//  LetgoURLHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 14/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class LetgoURLHelper {
    private static let langsCountryDict = [
        "de":"de",  // https://de.letgo.com/de/something
        "el":"gr",  // https://gr.letgo.com/el/something
        "en":"us",  // https://us.letgo.com/en/something
        "es":"es",  // https://es.letgo.com/es/something
        "fi":"fi",  // https://fi.letgo.com/fi/something
        "fr":"fr",  // https://fr.letgo.com/fr/something
        "hu":"hu",  // https://hu.letgo.com/hu/something
        "it":"it",  // https://it.letgo.com/it/something
        "nb":"no",  // https://no.letgo.com/nb/something
        "nl":"nl",  // https://nl.letgo.com/nl/something
        "ru":"ru",  // https://ru.letgo.com/ru/something
        "sv":"se",  // https://se.letgo.com/sv/something
        "tr":"tr",  // https://tr.letgo.com/tr/something
        "vi":"vn",  // https://vn.letgo.com/vi/something
        "pt":"pt",  // https://pt.letgo.com/pt/something
        "ko":"kr"   // https://kr.letgo.com/ko/something
    ]
    private static let defaultLang = "en"
    private static let defaultCountry = "us"

    static func composeURL(baseUrl: String, preferredLanguage: String? = nil) -> NSURL? {
        let prefLanguage = preferredLanguage ?? systemLanguage()

        var language = LetgoURLHelper.defaultLang
        var country = LetgoURLHelper.defaultCountry
        if let preferredCountry = LetgoURLHelper.langsCountryDict[prefLanguage] {
            language = prefLanguage
            country = preferredCountry
        }
        let urlString = String(format: baseUrl, arguments: [country, language])
        return NSURL(string: urlString)
    }

    private static func systemLanguage() -> String {
        guard let systemLanguage = NSLocale.preferredLanguages().first else { return LetgoURLHelper.defaultLang }
        let components = systemLanguage.componentsSeparatedByString("-")
        // In case it's like es-ES, just take the first "es"
        guard let firstComponent = components.first else { return LetgoURLHelper.defaultLang }
        return firstComponent.lowercaseString
    }
}