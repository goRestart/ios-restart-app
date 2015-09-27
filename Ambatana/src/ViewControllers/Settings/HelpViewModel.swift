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
            if !contains(HelpViewModel.availableHelpLangs, language) {
                language = HelpViewModel.defaultLang
            }
        }
        let urlString = String(format: Constants.helpURL, arguments: [language])
        return NSURL(string: urlString)
    }
}
