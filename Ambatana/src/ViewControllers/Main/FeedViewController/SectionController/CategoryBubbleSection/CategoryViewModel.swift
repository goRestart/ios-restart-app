import LGCoreKit

protocol CategoriesBubblePresentable: CategoriesHeaderCollectionViewDelegate {
    var categories: [CategoryHeaderElement] { get }
    var categoryHighlighted: CategoryHeaderElement { get }
}

final class CategoryViewModel: CategoriesBubblePresentable {
    
    private let featureFlags: FeatureFlaggeable
    weak var delegate: CategoriesHeaderCollectionViewDelegate?
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
    }
    
    var categories: [CategoryHeaderElement] {
        return ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                   realEstateIncluded: featureFlags.realEstateEnabled.isActive,
                                                   servicesHighlighted: true)
            .map { CategoryHeaderElement.listingCategory($0) }
    }
    
    var categoryHighlighted: CategoryHeaderElement {
        if featureFlags.realEstateEnabled.isActive {
            return CategoryHeaderElement.listingCategory(.realEstate)
        } else {
            return CategoryHeaderElement.listingCategory(.cars)
        }
    }
}

extension CategoryViewModel {
    
    func openTaxonomyList() {
        delegate?.openTaxonomyList()
    }
    
    func categoryHeaderDidSelect(categoryHeaderInfo: CategoryHeaderInfo) {
        delegate?.categoryHeaderDidSelect(categoryHeaderInfo: categoryHeaderInfo)
    }

}


