//
//  ProductSortBy.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

public enum ProductSortOption: String {
    case Closest = "closest", Newest = "newest", PriceAsc = "price_asc", PriceDesc = "price_desc"
    
    public static func allValues() -> [ProductSortOption] { return [.Closest, .Newest, .PriceAsc, .PriceDesc] }
}

extension ProductSortOption {
    
    public static var defaultOption : ProductSortOption {
        return .Closest
    }
    
    public var name : String {
        switch(self) {
        case .Closest:
            return LGLocalizedString.filtersSortClosest
        case .Newest:
            return LGLocalizedString.filtersSortNewest
        case .PriceAsc:
            return LGLocalizedString.filtersSortPriceAsc
        case .PriceDesc:
            return LGLocalizedString.filtersSortPriceDesc
        }
    }
    
}
