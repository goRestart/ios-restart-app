import LGCoreKit
import LGComponents

enum FilterCarSection {
    case firstSection, secondSection, make, model, year, bodyType,
        transmission, fuelType, driveTrain, mileage, numberOfSeats
    
    static func all(showCarExtraFilters: Bool) -> [FilterCarSection] {
        if showCarExtraFilters {
            return [.firstSection, .secondSection, .make, .model,
             .year, .mileage, .bodyType, .transmission, .fuelType, .driveTrain, .numberOfSeats]
        }
        
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
        case .bodyType:
            return R.Strings.filtersCarsBodytypeTitle
        case .transmission:
            return R.Strings.filtersCarsTransmissionTitle
        case .fuelType:
            return R.Strings.filtersCarsFueltypeTitle
        case .driveTrain:
            return R.Strings.filtersCarsDrivetrainTitle
        case .mileage:
            return R.Strings.filtersMileageSliderTitle
        case .numberOfSeats:
            return R.Strings.filtersNumberOfSeatsSliderTitle
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
