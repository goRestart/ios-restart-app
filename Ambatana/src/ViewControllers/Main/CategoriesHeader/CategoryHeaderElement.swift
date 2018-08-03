import LGCoreKit
import LGComponents

enum CategoryHeaderElement {
    case listingCategory(ListingCategory)
    case superKeyword(TaxonomyChild)
    case superKeywordGroup(Taxonomy)
    case showMore
    
    var name: String {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.nameInFeed
        case .superKeyword(let taxonomyChild):
            return taxonomyChild.name
        case .superKeywordGroup(let taxonomy):
            return taxonomy.name
        case .showMore:
            return R.Strings.categoriesSuperKeywordsInFeedShowMore
        }
    }
    
    var imageIconURL: URL? {
        switch self {
        case .listingCategory, .showMore:
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
            return R.Asset.IconsButtons.CategoriesHeaderIcons.showMore.image
        }
    }
    
    var isCarCategory: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isCar
        case .superKeyword, .superKeywordGroup, .showMore:
            return false
        }
    }
    
    var isSuperKeyword: Bool {
        switch self {
        case .listingCategory, .superKeywordGroup, .showMore:
            return false
        case .superKeyword:
            return true
        }
    }
    
    var isRealEstate: Bool {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory.isRealEstate
        case .superKeyword, .superKeywordGroup, .showMore:
            return false
        }
    }
}

func ==(a: CategoryHeaderElement, b: CategoryHeaderElement) -> Bool {
    switch (a, b) {
    case (.listingCategory(let catA), .listingCategory(let catB)) where catA == catB: return true
    case (.superKeyword(let catA), .superKeyword(let catB)) where catA == catB: return true
    case (.superKeywordGroup(let catA), .superKeywordGroup(let catB)) where catA == catB: return true
    default: return false
    }
}
