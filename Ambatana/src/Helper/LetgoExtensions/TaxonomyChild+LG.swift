//
//  TaxonomyChild+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension TaxonomyChild {
    
    var category: ListingCategory? {
        switch type {
        case .category:
            return ListingCategory.init(rawValue: self.id)
        case .superKeyword:
            return nil
        }
    }
    
    var isCarsCategory: Bool {
        switch type {
        case .category:
            if let categoryValue = category {
                return categoryValue.isCar
            } else {
                return false
            }
        case .superKeyword:
            return false
        }
    }
    
    var isOthers: Bool {
        return id == 90
    }
}

extension Array where Element == TaxonomyChild {
    func getIds(withType type: TaxonomyChildType) -> [Int] {
       return self.filter { $0.type == type }.flatMap { $0.id }
    }
}
