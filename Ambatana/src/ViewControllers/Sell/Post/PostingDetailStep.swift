import Foundation
import LGComponents

enum PostingDetailStep {
    case price
    case propertyType
    case offerType
    case bedrooms
    case rooms
    case sizeSquareMeters
    case bathrooms
    case location
    case make
    case model
    case year
    case summary
    
    var title: String {
        switch self {
        case .price:
            return R.Strings.realEstatePriceTitle
        case .propertyType:
            return R.Strings.realEstateTypePropertyTitle
        case .offerType:
            return R.Strings.realEstateOfferTypeTitle
        case .bedrooms:
            return R.Strings.realEstateBedroomsTitle
        case .rooms:
            return R.Strings.realEstateRoomsTitle
        case .sizeSquareMeters:
            return R.Strings.realEstateSizeSquareMetersTitle
        case .bathrooms:
            return R.Strings.realEstateBathroomsTitle
        case .summary:
            return R.Strings.realEstateSummaryTitle
        case .location:
            return R.Strings.realEstateLocationTitle
        case .make:
            return R.Strings.postCategoryDetailCarMake
        case .model:
            return R.Strings.postCategoryDetailCarModel
        case .year:
            return R.Strings.postCategoryDetailCarYear
        }
    }
    
    func nextStep(postingFlowType: PostingFlowType) -> PostingDetailStep? {
        switch self {
        case .price:
            return .propertyType
        case .propertyType:
            return .offerType
        case .offerType:
            return postingFlowType == .standard ? .bedrooms : .rooms
        case .rooms:
            return .sizeSquareMeters
        case .sizeSquareMeters:
            return .summary
        case .bedrooms:
            return .bathrooms
        case .bathrooms:
            return .summary
        case .summary:
            return nil
        case .location:
            return .summary
        case .make:
            return .model
        case .model:
            return .year
        case .year:
            return .summary
        }
    }
}
