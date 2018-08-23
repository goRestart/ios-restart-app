import LGComponents

enum FilterServicesSection {
    case type, subtype, unified
    
    static func allSections(isUnifiedActive: Bool) -> [FilterServicesSection] {
        return isUnifiedActive ? [.unified] : [.type, .subtype]
    }
    
    var title: String {
        switch self {
        case .type:
            return FeatureFlags.sharedInstance.jobsAndServicesEnabled.isActive ?
                R.Strings.filtersJobsServicesTypeTitle : R.Strings.servicesServiceTypeTitle
        case .subtype:
            return FeatureFlags.sharedInstance.jobsAndServicesEnabled.isActive ?
                R.Strings.filtersJobsServicesSubtypeTitle : R.Strings.servicesServiceSubtypeTitle
        case .unified:
            return R.Strings.servicesUnifiedFilterTitle
        }
    }
}

