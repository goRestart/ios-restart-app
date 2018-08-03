import LGCoreKit
import LGComponents

protocol CategoriesHeaderCellPresentable {
    var categories: [CategoryHeaderElement] { get }
    var categoryHighlighted: CategoryHeaderElement { get }
}

final class CategoryPresenter: BaseViewModel {
    
    private let featureFlags: FeatureFlaggeable
    
    
    // MARK:- Lifecycle
    
    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.featureFlags = featureFlags
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return CategoriesFeedHeaderCell.self
    }
    
    var height: CGFloat {
        return CategoriesFeedHeaderCell.viewHeight
    }
}

extension CategoryPresenter: CategoriesHeaderCellPresentable {
    
    var categories: [CategoryHeaderElement] {
        var categoryHeaderElements: [CategoryHeaderElement] = []
        categoryHeaderElements.append(contentsOf: ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                                                      realEstateIncluded: featureFlags.realEstateEnabled.isActive,
                                                                                      servicesHighlighted: false)
            .map { CategoryHeaderElement.listingCategory($0) })
        return categoryHeaderElements
    }
    
    var categoryHighlighted: CategoryHeaderElement {
        if featureFlags.realEstateEnabled.isActive {
            return CategoryHeaderElement.listingCategory(.realEstate)
        } else {
            return CategoryHeaderElement.listingCategory(.cars)
        }
    }
}
