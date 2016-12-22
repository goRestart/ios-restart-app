//
//  FilterSection.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public enum FilterSection: Int {
    case Location, Categories, Distance, SortBy, Within, Price
}

extension FilterSection {
    
    public var name : String {
        switch(self) {
        case .Location:

            return LGLocalizedString.filtersSectionLocation.uppercase
        case .Distance:
            return LGLocalizedString.filtersSectionDistance.uppercase
        case .Categories:
            return LGLocalizedString.filtersSectionCategories.uppercase
        case .Within:
            return LGLocalizedString.filtersSectionWithin.uppercase
        case .SortBy:
            return LGLocalizedString.filtersSectionSortby.uppercase
        case .Price:
            return LGLocalizedString.filtersSectionPrice.uppercase
        }
    }
    
    static var allValues: [FilterSection] {
        return [.Location, .Categories, .Distance, .SortBy, .Within, .Price]
    }
    
}
