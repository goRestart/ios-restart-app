//
//  Product+Title.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

extension Listing {

    var title: String? {
        return ListingHelper.titleWith(name: name, nameAuto: nameAuto)
    }

    var description: String? {
        return ListingHelper.descriptionWith(descr: descr)
    }

    var isTitleAutoGenerated: Bool {
        if let name = name?.trim, !name.isEmpty {
            return false
        } else if let nameAuto = nameAuto?.trim, !nameAuto.isEmpty {
            return true
        }
        return false
    }
    func isTitleAutoTranslated(_ countryHelper: CountryHelper) -> Bool {
        guard isTitleAutoGenerated else { return false }
        guard let languageCode = countryHelper.countryLanguageFor(listing: self) else { return false }
        return languageCode != "en"
    }
}

extension Product {

    var title: String? {
        return ListingHelper.titleWith(name: name, nameAuto: nameAuto)
    }

    var description: String? {
        return ListingHelper.descriptionWith(descr: descr)
    }

    var isTitleAutoGenerated: Bool {
        if let name = name?.trim, !name.isEmpty {
            return false
        } else if let nameAuto = nameAuto?.trim, !nameAuto.isEmpty {
            return true
        }
        return false
    }
    func isTitleAutoTranslated(_ countryHelper: CountryHelper) -> Bool {
        guard isTitleAutoGenerated else { return false }
        guard let languageCode = countryHelper.countryLanguageForProduct(self) else { return false }
        return languageCode != "en"
    }
}


class ListingHelper {
    static func titleWith(name: String?, nameAuto: String?) -> String? {
        var result: String? = nil
        if let name = name?.trim, !name.isEmpty {
            result = name.capitalizedFirstLetterOnly
        } else if let nameAuto = nameAuto?.trim, !nameAuto.isEmpty {
            result = nameAuto.capitalizedFirstLetterOnly
        }

        return result?.replacingHiddenTags
    }

    static func descriptionWith(descr: String?) -> String? {
        return descr?.capitalizedFirstLetterOnly.replacingHiddenTags
    }
}