
import LGCoreKit
import LGComponents

enum FilterCategoryItem: Equatable {
    case category(category: ListingCategory)
    case free
    
    init(category: ListingCategory) {
        self = .category(category: category)
    }
    
    var name: String {
        switch self {
        case let .category(category: category):
            return category.name
        case .free:
            return R.Strings.categoriesFree
        }
    }
    
    var icon: UIImage? {
        switch self {
        case let .category(category: category):
            return category.image
        case .free:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesFreeInactive.image
        }
    }
}

func ==(a: FilterCategoryItem, b: FilterCategoryItem) -> Bool {
    switch (a, b) {
    case (.category(let catA), .category(let catB)) where catA.rawValue == catB.rawValue: return true
    case (.free, .free): return true
    default: return false
    }
}
