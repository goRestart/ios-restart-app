//
//  FilterSection.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public enum FilterSection: Int {
    case location, categories, distance, sortBy, within, price
}

extension FilterSection {
    
    public var name : String {
        switch(self) {
        case .location:

            return LGLocalizedString.filtersSectionLocation.uppercase
        case .distance:
            return LGLocalizedString.filtersSectionDistance.uppercase
        case .categories:
            return LGLocalizedString.filtersSectionCategories.uppercase
        case .within:
            return LGLocalizedString.filtersSectionWithin.uppercase
        case .sortBy:
            return LGLocalizedString.filtersSectionSortby.uppercase
        case .price:
            return LGLocalizedString.filtersSectionPrice.uppercase
        }
    }
    
    static var allValues: [FilterSection] {
        return [.location, .categories, .distance, .sortBy, .within, .price]
    }
    
}
