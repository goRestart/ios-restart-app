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
    case superKeyword(TaxonomyChild)
    case other
    
    var name: String {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.nameInFeed
        case .superKeyword(let taxonomyChild):
            return taxonomyChild.name
        case .other:
            return LGLocalizedString.categoriesSuperKeywordsInfeedShowMore
        }
    }
    
    var imageIconURL: URL? {
        switch self {
        case .listingCategory, .other:
            return nil
        case .superKeyword(let taxonomyChild):
            return taxonomyChild.highlightIcon
        }
    }
    
    var imageIcon: UIImage? {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.imageInFeed
        case .superKeyword:
            return nil
        case .other:
            return #imageLiteral(resourceName: "showMore")
        }
    }
    
    var isCarCategory: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isCar
        case .superKeyword, .other:
            return false
        }
    }
    
    var isCategory: Bool {
        switch self {
        case .listingCategory:
            return true
        case .superKeyword, .other:
            return false
        }
    }
    
    var isSuperKeyword: Bool {
        switch self {
        case .listingCategory, .other:
            return false
        case .superKeyword:
            return true
        }
    }
    
    var isOther: Bool {
        switch self {
        case .listingCategory, .superKeyword:
            return false
        case .other:
            return true
        }
    }
}
