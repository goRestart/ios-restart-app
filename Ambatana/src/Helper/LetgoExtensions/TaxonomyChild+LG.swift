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
    
    var isCarsTaxonomy: Bool {
        switch type {
        case .category:
            if let categoryValue = category {
                return categoryValue.isCar
            } else {
                return false
            }
        case .superKeyword:
            return isCarsSuperKeyword
        }
    }
    
    var isCarsSuperKeyword: Bool {
        return id == 20
    }
}

extension Array where Element == TaxonomyChild {
    func getIds(withType type: TaxonomyChildType) -> [Int] {
       return self.filter { $0.type == type }.compactMap { $0.id }
    }
}

extension Array where Element == TaxonomyChild {
    var containsCarsTaxonomy: Bool {
        return self.reduce(false) { (result, taxonomyChild) -> Bool in
            let isCarsCategory = taxonomyChild.isCarsTaxonomy
            return result || isCarsCategory
        }
    }
}
