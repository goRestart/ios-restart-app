//
//  CategoryHeaderElement.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

enum CategoryHeaderElement {
    case listingCategory(ListingCategory)
    case superKewword(TaxonomyChild)
    
    var name: String {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.nameInFeed
        case .superKewword(let taxonomyChild):
            return taxonomyChild.name
        }
    }
    
    var imageIconURL: URL? {
        switch self {
        case .listingCategory:
            return nil
        case .superKewword(let taxonomyChild):
            return taxonomyChild.highlightIcon
        }
    }
    
    var imageIcon: UIImage? {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.imageInFeed
        case .superKewword:
            return nil
        }
    }
    
    var isCarCategory: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isCar
        case .superKewword:
            return false
        }
    }
}
