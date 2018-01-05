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
    case superKeywordGroup(Taxonomy)
    case showMore
    case mostSearchedItems
    
    var name: String {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.nameInFeed
        case .superKeyword(let taxonomyChild):
            return taxonomyChild.name
        case .superKeywordGroup(let taxonomy):
            return taxonomy.name
        case .showMore:
            return LGLocalizedString.categoriesSuperKeywordsInfeedShowMore
        case .mostSearchedItems:
            // TODO: Localize when specs finished
            return "Trending"
        }
    }
    
    var imageIconURL: URL? {
        switch self {
        case .listingCategory, .showMore, .mostSearchedItems:
            return nil
        case .superKeyword(let taxonomyChild):
            return taxonomyChild.highlightIcon
        case .superKeywordGroup(let taxonomy):
            return taxonomy.icon
        }
    }
    
    var imageIcon: UIImage? {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.imageInFeed
        case .superKeyword, .superKeywordGroup:
            return nil
        case .showMore:
            return #imageLiteral(resourceName: "showMore")
        case .mostSearchedItems:
            return #imageLiteral(resourceName: "trending_feed")
        }
    }
    
    var isCarCategory: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isCar
        case .superKeyword, .superKeywordGroup, .showMore, .mostSearchedItems:
            return false
        }
    }
    
    var isCategory: Bool {
        switch self {
        case .listingCategory:
            return true
        case .superKeyword, .superKeywordGroup, .showMore, .mostSearchedItems:
            return false
        }
    }
    
    var isSuperKeyword: Bool {
        switch self {
        case .listingCategory, .superKeywordGroup, .showMore, .mostSearchedItems:
            return false
        case .superKeyword:
            return true
        }
    }
    
    var isSuperKeywordGroup: Bool {
        switch self {
        case .listingCategory, .superKeyword, .showMore, .mostSearchedItems:
            return false
        case .superKeywordGroup:
            return true
        }
    }
    
    var isShowMore: Bool {
        switch self {
        case .listingCategory, .superKeyword, .superKeywordGroup, .mostSearchedItems:
            return false
        case .showMore:
            return true
        }
    }
    
    var isMostSearchedItems: Bool {
        switch self {
        case .listingCategory, .superKeyword, .superKeywordGroup, .showMore:
            return false
        case .mostSearchedItems:
            return true
        }
    }
}
