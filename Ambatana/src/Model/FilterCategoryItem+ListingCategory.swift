import LGCoreKit

extension FilterCategoryItem {
    static func makeForFeed(with featureFlags: FeatureFlaggeable) -> [FilterCategoryItem] {
        let realEstateEnabled = featureFlags.realEstateEnabled.isActive
        let categories = ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                             realEstateIncluded: realEstateEnabled,
                                                             servicesHighlighted: true)
        let filters = categories.map { FilterCategoryItem.category(category: $0) }

        return filters
    }
}
