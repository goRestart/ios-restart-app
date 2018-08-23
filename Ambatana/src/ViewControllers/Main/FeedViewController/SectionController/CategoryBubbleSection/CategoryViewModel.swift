import LGCoreKit

protocol CategoriesBubblePresentable: CategoriesHeaderCollectionViewDelegate {
    var categories: [ListingCategory] { get }
    var categoryHighlighted: ListingCategory { get }
}

final class CategoryViewModel: CategoriesBubblePresentable {
    
    private let featureFlags: FeatureFlaggeable
    weak var delegate: CategoriesHeaderCollectionViewDelegate?
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
    }
    
    var categories: [ListingCategory] {
        return ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                   realEstateIncluded: featureFlags.realEstateEnabled.isActive,
                                                   servicesHighlighted: true)
    }
    
    var categoryHighlighted: ListingCategory {
        if featureFlags.realEstateEnabled.isActive {
            return .realEstate
        } else {
            return .cars
        }
    }
}

extension CategoryViewModel {
    
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        delegate?.categoryHeaderDidSelect(categoryHeaderInfo: categoryHeaderInfo)
    }

}


