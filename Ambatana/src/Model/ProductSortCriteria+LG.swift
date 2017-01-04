//
//  ProductSortCriteria+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductSortCriteria {
    static var defaultOption : ProductSortCriteria? {
        return nil
    }
    
    var name : String {
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
    
    static func allValues() -> [ProductSortCriteria] {
        return [.Creation, .Distance, .PriceAsc, .PriceDesc]
    }
}
