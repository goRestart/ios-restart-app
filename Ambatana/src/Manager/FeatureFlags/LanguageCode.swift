//
//  LanguageCode.swift
//  LetGo
//
//  Created by Juan Iglesias on 10/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum LanguageCode: String {
    case english = "en"
    case spanish = "es"
    
    init?(locale: Locale) {
        guard let languageCode = locale.languageCode else { return nil }
        self.init(rawValue: languageCode)
    }
}
