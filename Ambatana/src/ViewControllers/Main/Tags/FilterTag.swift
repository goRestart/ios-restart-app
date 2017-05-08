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
    case within(ListingTimeCriteria)
    case orderBy(ListingSortCriteria)
    case category(ListingCategory)
    case priceRange(from: Int?, to: Int?, currency: Currency?)
    case freeStuff
    case distance(distance: Int)
    case make(id: String, name: String)
    case model(id: String, name: String)
    case yearsRange(from: Int?, to: Int?)
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
    case (.make(let idA, let nameA), .make(let idB, let nameB)) where idA == idB && nameA == nameB: return true
    case (.model(let idA, let nameA), .model(let idB, let nameB)) where idA == idB && nameA == nameB: return true
    case (.yearsRange(let a, let b), .yearsRange(let c, let d)) where a == c && b == d: return true
    default: return false
    }
}
