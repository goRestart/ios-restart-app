//
//  ProductSortCriteria+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductSortCriteria {
    public static var defaultOption : ProductSortCriteria {
        if ABTests.defaultFilterOrderNewest.boolValue {
            return .Creation
        }
        else {
            return .Distance
        }
    }
    
    public var name : String {
        switch(self) {
        case .Distance:
            return LGLocalizedString.filtersSortClosest
        case .Creation:
            return LGLocalizedString.filtersSortNewest
        case .PriceAsc:
            return LGLocalizedString.filtersSortPriceAsc
        case .PriceDesc:
            return LGLocalizedString.filtersSortPriceDesc
        }
    }
    
    public static func allValues() -> [ProductSortCriteria] {
        if ABTests.defaultFilterOrderNewest.boolValue {
            return [.Creation, .Distance, .PriceAsc, .PriceDesc]
        }
        else {
            return [.Distance, .Creation, .PriceAsc, .PriceDesc]
        }
    }
}