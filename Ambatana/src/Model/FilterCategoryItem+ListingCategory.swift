import LGCoreKit

extension FilterCategoryItem {
    static func makeForFeed(with featureFlags: FeatureFlaggeable) -> [FilterCategoryItem] {
        let realEstateEnabled = featureFlags.realEstateEnabled.isActive
        let categories = ListingCategory.visibleValuesInFeed(servicesIncluded: true,
                                                             realEstateIncluded: realEstateEnabled,
                                                             servicesHighlighted: true)
        var filters = categories.map { FilterCategoryItem.category(category: $0) }
        if featureFlags.freePostingModeAllowed && featureFlags.shouldHightlightFreeFilterInFeed {
            let index = categories.index(of: .electronics) ?? 0
            filters.insert(.free, at: index + 1)
        }

        return filters
    }
}
