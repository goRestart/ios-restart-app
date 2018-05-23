//
//  ListingSortCriteria+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingSortCriteria {
    static var defaultOption : ListingSortCriteria? {
        return nil
    }
    
    var name : String {
        switch(self) {
        case .distance:
            return LGLocalizedString.filtersSortClosest
        case .creation:
            return LGLocalizedString.filtersSortNewest
        case .priceAsc:
            return LGLocalizedString.filtersSortPriceAsc
        case .priceDesc:
            return LGLocalizedString.filtersSortPriceDesc
        }
    }
    
    static func allValues() -> [ListingSortCriteria] {
        return [.creation, .distance, .priceAsc, .priceDesc]
    }
    
    var trackValue: EventParameterSortBy {
        switch self {
        case .distance:
            return .distance
        case .creation:
            return .creationDate
        case .priceAsc:
            return .priceAsc
        case .priceDesc:
            return .priceDesc
        }
    }
}
