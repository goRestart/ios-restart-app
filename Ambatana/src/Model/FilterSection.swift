//
//  FilterSection.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

enum FilterSection: Int {
    case location, categories, carsInfo, distance, sortBy, within, price, realEstateInfo
}

extension FilterSection {
    
    var name : String {
        switch(self) {
        case .location:
            return LGLocalizedString.filtersSectionLocation.localizedUppercase
        case .distance:
            return LGLocalizedString.filtersSectionDistance.localizedUppercase
        case .categories:
            return LGLocalizedString.filtersSectionCategories.localizedUppercase
        case .carsInfo:
            return LGLocalizedString.filtersSectionCarInfo.localizedUppercase
        case .within:
            return LGLocalizedString.filtersSectionWithin.localizedUppercase
        case .sortBy:
            return LGLocalizedString.filtersSectionSortby.localizedUppercase
        case .price:
            return LGLocalizedString.filtersSectionPrice.localizedUppercase
        case .realEstateInfo:
            return "Real estate section"
        }
    }

    static func allValues(priceAsLast: Bool) -> [FilterSection] {
        if priceAsLast {
            return [.location, .categories, .carsInfo, .realEstateInfo, .distance, .sortBy, .within, .price]
        } else {
            return [.location, .distance, .categories, .price, .carsInfo, .realEstateInfo, .sortBy, .within]
        }
    }
}
