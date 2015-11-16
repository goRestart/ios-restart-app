//
//  FilterTag.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum FilterTag : Equatable{
    case OrderBy(ProductSortOption)
    case Category(ProductCategory)
}

func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.OrderBy(let a),   .OrderBy(let b))   where a == b: return true
    case (.Category(let a), .Category(let b)) where a == b: return true
    default: return false
    }
}