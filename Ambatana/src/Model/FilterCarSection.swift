import LGCoreKit
import LGComponents

enum FilterCarSection {
    case firstSection, secondSection, make, model, year
    
    static var all: [FilterCarSection] {
        return [.firstSection, .secondSection, .make, .model, .year]
    }
    
    var isCarSellerTypeSection: Bool {
        return self == .firstSection || self == .secondSection
    }
    
    var isFirstSection: Bool {
        return self == .firstSection
    }
    
    func title(feature: FilterSearchCarSellerType) -> String {
        switch self {
        case .firstSection:
            return feature.firstSectionTitle
        case .secondSection:
            return feature.secondSectionTitle
        case .make:
            return R.Strings.postCategoryDetailCarMake
        case .model:
            return R.Strings.postCategoryDetailCarModel
        case .year:
            return ""
        }
    }
}

extension FilterCarSection {
    var carSellerType: UserType {
        guard case .firstSection = self else { return .pro }
        return .user
    }
}

private extension FilterSearchCarSellerType {
    var firstSectionTitle: String {
        switch self {
        case .control, .baseline:
            return ""
        case .variantA:
            return R.Strings.filtersCarSellerTypePrivate
        case .variantB:
            return R.Strings.filtersCarSellerTypeInvidual
        case .variantC, .variantD:
            return R.Strings.filtersCarSellerTypeAll
        }
    }
    
    var secondSectionTitle: String {
        switch self {
        case .control, .baseline:
            return ""
        case .variantA, .variantC:
            return R.Strings.filtersCarSellerTypeProfessional
        case .variantB, .variantD:
            return R.Strings.filtersCarSellerTypeDealership
        }
    }
}
