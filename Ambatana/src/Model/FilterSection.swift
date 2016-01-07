//
//  FilterSection.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public enum FilterSection {
    case Distance, Categories, Within, SortBy
}

extension FilterSection {
    
    public var name : String {
        switch(self) {
        case .Distance:
            return LGLocalizedString.filtersSectionDistance.uppercaseString
        case .Categories:
            return LGLocalizedString.filtersSectionCategories.uppercaseString
        case .Within:
            return LGLocalizedString.filtersSectionWithin.uppercaseString
        case .SortBy:
            return LGLocalizedString.filtersSectionSortby.uppercaseString
        }
    }
    
    public static func allValues()  -> [FilterSection] {
        return [.Distance, .Categories, .Within, .SortBy]
    }
    
}
