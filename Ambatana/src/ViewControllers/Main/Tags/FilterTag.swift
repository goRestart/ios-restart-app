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
    case category(ListingCategory)
    case priceRange(from: Int?, to: Int?, currency: Currency?)
    case freeStuff
    case distance(distance: Int)
}

func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.location, .location): return true
    case (.within(let a),   .within(let b))   where a == b: return true
    case (.orderBy(let a),   .orderBy(let b))   where a == b: return true
    case (.category(let a), .category(let b)) where a == b: return true
    case (.priceRange(let a, let b, _), .priceRange(let c, let d, _)) where a == c && b == d: return true
    case (.freeStuff, .freeStuff): return true
    case (.distance(let distanceA), .distance(let distanceB)) where distanceA == distanceB: return true
    default: return false
    }
}
