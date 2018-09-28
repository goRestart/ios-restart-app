import LGCoreKit
import LGComponents

enum FilterCarSection {
    case individual, dealership,
    make, model, year, bodyType,
    transmission, fuelType, driveTrain, mileage, numberOfSeats
    
    static var allCases: [FilterCarSection] {
        return [.individual, .dealership,
                .make, .model, .year,
                .mileage, .bodyType, .transmission, .fuelType, .driveTrain, .numberOfSeats]
    }
    
    var isCarSellerTypeSection: Bool {
        return self == .individual || self == .dealership
    }
    
    var title: String {
        switch self {
        case .individual:
            return R.Strings.filtersCarSellerTypeInvidual
        case .dealership:
            return R.Strings.filtersCarSellerTypeDealership
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
        guard case .individual = self else { return .pro }
        return .user
    }
}
