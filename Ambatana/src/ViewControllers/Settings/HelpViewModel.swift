//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

public class HelpViewModel: BaseViewModel {
   
    public var url: NSURL? {
        let preferredLanguages = NSLocale.preferredLanguages()
        let language: String
        if !preferredLanguages.isEmpty {
            language = preferredLanguages[0] as? String ?? "en"
        }
        else {
            language = "en"
        }
        let urlString = String(format: Constants.helpURL, arguments: [language])
        return NSURL(string: urlString)
    }
}
