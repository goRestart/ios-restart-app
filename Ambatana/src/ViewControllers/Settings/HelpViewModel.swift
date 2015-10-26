//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class HelpViewModel: BaseViewModel {
   
    private static let langsCountryDict = [
        "de":"de",  // http://de.letgo.com/de/help_app
        "el":"gr",  // http://gr.letgo.com/el/help_app
        "en":"us",  // http://us.letgo.com/en/help_app
        "es":"es",  // http://es.letgo.com/es/help_app
        "fi":"fi",  // http://fi.letgo.com/fi/help_app
        "fr":"fr",  // http://fr.letgo.com/fr/help_app
        "hu":"hu",  // http://hu.letgo.com/hu/help_app
        "it":"it",  // http://it.letgo.com/it/help_app
        "nb":"no",  // http://no.letgo.com/nb/help_app
        "nl":"nl",  // http://nl.letgo.com/nl/help_app
        "ru":"ru",  // http://ru.letgo.com/ru/help_app
        "sv":"se",  // http://se.letgo.com/sv/help_app
        "tr":"tr",  // http://tr.letgo.com/tr/help_app
        "vi":"vn",  // http://vn.letgo.com/vi/help_app
        "pt":"pt",  // http://pt.letgo.com/pt/help_app
        "ko":"kr"   // http://kr.letgo.com/ko/help_app
    ]
    private static let defaultLang = "en"
    private static let defaultCountry = "us"
    
    public var url: NSURL? {
        let preferredLanguages = NSLocale.preferredLanguages()
        
        var language = HelpViewModel.defaultLang
        var country = HelpViewModel.defaultCountry
        
        if !preferredLanguages.isEmpty {
            language = preferredLanguages[0] ?? HelpViewModel.defaultLang
            
            // In case it's like es-ES, just take the first "es"
            let components = language.componentsSeparatedByString("-")
            language = components.count > 0 ? components[0] : HelpViewModel.defaultLang
            if !HelpViewModel.langsCountryDict.keys.contains(language) {
                language = HelpViewModel.defaultLang
            }
            country = HelpViewModel.langsCountryDict[language] ?? HelpViewModel.defaultCountry
        }
        let urlString = String(format: Constants.helpURL, arguments: [country, language])
        return NSURL(string: urlString)
    }
}
