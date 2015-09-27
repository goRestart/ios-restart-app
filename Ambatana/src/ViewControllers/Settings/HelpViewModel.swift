//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class HelpViewModel: BaseViewModel {
   
    private static let availableHelpLangs = ["de", "el", "en", "es", "fi", "fr", "hu", "it", "nb", "nl", "ru", "sv", "tr", "vi"]
    private static let defaultLang = "en"
    
    public var url: NSURL? {
        let preferredLanguages = NSLocale.preferredLanguages()
        var language: String = HelpViewModel.defaultLang
        if !preferredLanguages.isEmpty {
            language = preferredLanguages[0] as? String ?? HelpViewModel.defaultLang
            
            // In case it's like es-ES, just take the first "es"
            let components = language.componentsSeparatedByString("-")
            if components.count > 0 {
                language = components[0]
            }
            // If the language is not supported the set English as default
            if !contains(HelpViewModel.availableHelpLangs, language) {
                language = HelpViewModel.defaultLang
            }
        }
        let urlString = String(format: Constants.helpURL, arguments: [language])
        return NSURL(string: urlString)
    }
}
