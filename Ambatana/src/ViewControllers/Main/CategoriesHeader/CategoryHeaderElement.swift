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
    case trending
    
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
        case .trending:
            return "Trending"
        }
    }
    
    var imageIconURL: URL? {
        switch self {
        case .listingCategory, .showMore, .trending:
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
        case .trending:
            return #imageLiteral(resourceName: "trending_feed")
        }
    }
    
    var isCarCategory: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isCar
        case .superKeyword, .superKeywordGroup, .showMore, .trending:
            return false
        }
    }
    
    var isCategory: Bool {
        switch self {
        case .listingCategory:
            return true
        case .superKeyword, .superKeywordGroup, .showMore, .trending:
            return false
        }
    }
    
    var isSuperKeyword: Bool {
        switch self {
        case .listingCategory, .superKeywordGroup, .showMore, .trending:
            return false
        case .superKeyword:
            return true
        }
    }
    
    var isSuperKeywordGroup: Bool {
        switch self {
        case .listingCategory, .superKeyword, .showMore, .trending:
            return false
        case .superKeywordGroup:
            return true
        }
    }
    
    var isShowMore: Bool {
        switch self {
        case .listingCategory, .superKeyword, .superKeywordGroup, .trending:
            return false
        case .showMore:
            return true
        }
    }
    
    var isTrending: Bool {
        switch self {
        case .listingCategory, .superKeyword, .superKeywordGroup, .showMore:
            return false
        case .trending:
            return true
        }
    }
}
