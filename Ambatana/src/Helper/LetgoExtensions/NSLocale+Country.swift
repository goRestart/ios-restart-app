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
    
    var realEstateBannerImage: UIImage {
        var image: UIImage? = nil
        if let languageCode = LanguageCode(locale: self) {
            switch languageCode {
            case .english:
                image = #imageLiteral(resourceName: "real_estate_banner_es")
            case .spanish:
                image = #imageLiteral(resourceName: "real_estate_banner_es")
            }
        }
        return image ?? #imageLiteral(resourceName: "real_estate_banner_en")
    }
}
