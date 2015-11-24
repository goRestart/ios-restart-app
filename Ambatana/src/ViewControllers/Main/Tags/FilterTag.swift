//
//  FilterTag.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum FilterTag : Equatable{
    case Within(ProductTimeCriteria)
    case OrderBy(ProductSortCriteria)
    case Category(ProductCategory)
}

public func ==(a: FilterTag, b: FilterTag) -> Bool {
    switch (a, b) {
    case (.Within(let a),   .Within(let b))   where a == b: return true
    case (.OrderBy(let a),   .OrderBy(let b))   where a == b: return true
    case (.Category(let a), .Category(let b)) where a == b: return true
    default: return false
    }
}