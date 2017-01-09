//
//  FilterTag.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum FilterTag: Equatable{
    case location(Place)
    case within(ProductTimeCriteria)
    case orderBy(ProductSortCriteria)
    case category(ProductCategory)
    case priceRange(from: Int?, to: Int?, currency: Currency?)
    case freeStuff
}

func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.Location, .Location): return true
    case (.Within(let a),   .Within(let b))   where a == b: return true
    case (.OrderBy(let a),   .OrderBy(let b))   where a == b: return true
    case (.category(let a), .category(let b)) where a == b: return true
    case (.PriceRange(let a, let b, _), .PriceRange(let c, let d, _)) where a == c && b == d: return true
    case (.freeStuff, .freeStuff): return true
    default: return false
    }
}
