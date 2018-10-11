import LGCoreKit

protocol CategoriesBubblePresentable: CategoriesHeaderCollectionViewDelegate {
    var categories: [FilterCategoryItem] { get }
    var categoryHighlighted: FilterCategoryItem { get }
}

final class CategoryViewModel: CategoriesBubblePresentable {
    
    private let featureFlags: FeatureFlaggeable
    private(set) var categories: [FilterCategoryItem]
    
    var categoryHighlighted: FilterCategoryItem { return FilterCategoryItem(category: .services) }

    weak var delegate: CategoriesHeaderCollectionViewDelegate?
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         categories: [ListingCategory]) {
        self.featureFlags = featureFlags
        self.categories = categories.map{ FilterCategoryItem.init(category: $0) }
    }
}

extension CategoryViewModel {
    
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        delegate?.categoryHeaderDidSelect(categoryHeaderInfo: categoryHeaderInfo)
    }

}


