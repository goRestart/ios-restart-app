import LGComponents

enum FilterSection: Int {
    case location, categories, carsInfo, distance, sortBy, within, price, realEstateInfo, servicesInfo, jobsServicesToggle
}

extension FilterSection {
    
    var name: String {
        switch(self) {
        case .location:
            return R.Strings.filtersSectionLocation.localizedUppercase
        case .distance:
            return R.Strings.filtersSectionDistance.localizedUppercase
        case .categories:
            return R.Strings.filtersSectionCategories.localizedUppercase
        case .carsInfo:
            return R.Strings.filtersSectionCarInfo.localizedUppercase
        case .within:
            return R.Strings.filtersSectionWithin.localizedUppercase
        case .sortBy:
            return R.Strings.filtersSectionSortby.localizedUppercase
        case .price:
            return R.Strings.filtersSectionPrice.localizedUppercase
        case .realEstateInfo:
            return R.Strings.filtersSectionRealEstateInfo.localizedUppercase
        case .servicesInfo:
            return FeatureFlags.sharedInstance.jobsAndServicesEnabled.isActive ? R.Strings.filtersJobsServicesHeader.localizedUppercase : R.Strings.filtersSectionServicesInfo.localizedUppercase
        case .jobsServicesToggle:
            return R.Strings.filtersJobsServicesToggleHeader.localizedUppercase
        }
    }
    
    var isRealEstateSection: Bool {
        return self == .realEstateInfo
    }

    static func allValues(priceAsLast: Bool) -> [FilterSection] {
        return [.location, .categories, .carsInfo, .realEstateInfo, .jobsServicesToggle, .servicesInfo, .distance, .sortBy, .within, .price]
    }
}
