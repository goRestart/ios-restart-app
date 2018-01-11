//
//  NSLocale+Country.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

extension Locale {
    var lg_countryCode: String {
        if #available(iOS 10.0, *) {
            return regionCode?.lowercased() ?? ""
        } else {
            return languageCode?.lowercased() ?? ""
        }
    }
}
