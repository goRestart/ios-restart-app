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
    
    //TODO: LOCALIZE!!
    
    public var name : String {
        switch(self) {
        case .Closest:
            return "Closest"
        case .Newest:
            return "Newest"
        case .PriceAsc:
            return "Price: Low to high"
        case .PriceDesc:
            return "Price: High to low"
        }
    }
    
}
