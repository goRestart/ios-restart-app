//
//  FilterTag.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum FilterTag: Equatable{
    case Location(Place)
    case Within(ProductTimeCriteria)
    case OrderBy(ProductSortCriteria)
    case Category(ProductCategory)
    case PriceRange(from: Int?, to: Int?, currency: Currency?)
}

public func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.Location, .Location): return true
    case (.Within(let a),   .Within(let b))   where a == b: return true
    case (.OrderBy(let a),   .OrderBy(let b))   where a == b: return true
    case (.Category(let a), .Category(let b)) where a == b: return true
    case (.PriceRange(let a, let b, _), .PriceRange(let c, let d, _)) where a == c && b == d: return true
    default: return false
    }
}
