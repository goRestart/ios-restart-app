import LGCoreKit

protocol CategoriesBubblePresentable: CategoriesHeaderCollectionViewDelegate {
    var categories: [FilterCategoryItem] { get }
    var categoryHighlighted: FilterCategoryItem { get }
}

final class CategoryViewModel: CategoriesBubblePresentable {
    
    private let featureFlags: FeatureFlaggeable
    weak var delegate: CategoriesHeaderCollectionViewDelegate?
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
    }
    
    var categories: [FilterCategoryItem] { return FilterCategoryItem.makeForFeed(with: featureFlags) }
    
    var categoryHighlighted: FilterCategoryItem {
        if featureFlags.realEstateEnabled.isActive {
            return FilterCategoryItem(category: .realEstate)
        } else {
            return FilterCategoryItem(category: .cars)
        }
    }
}

extension CategoryViewModel {
    
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        delegate?.categoryHeaderDidSelect(categoryHeaderInfo: categoryHeaderInfo)
    }

}


