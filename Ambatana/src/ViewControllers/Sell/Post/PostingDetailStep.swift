//
//  PostingDetailStep.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation


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
            return LGLocalizedString.realEstatePriceTitle
        case .propertyType:
            return LGLocalizedString.realEstateTypePropertyTitle
        case .offerType:
            return LGLocalizedString.realEstateOfferTypeTitle
        case .bedrooms:
            return LGLocalizedString.realEstateBedroomsTitle
        case .rooms:
            //TODO: add string
            return "Rooms"
        case .sizeSquareMeters:
            //TODO: add string
            return "sizeSquareMeters"
        case .bathrooms:
            return LGLocalizedString.realEstateBathroomsTitle
        case .summary:
            return LGLocalizedString.realEstateSummaryTitle
        case .location:
            return LGLocalizedString.realEstateLocationTitle
        case .make:
            return LGLocalizedString.postCategoryDetailCarMake
        case .model:
            return LGLocalizedString.postCategoryDetailCarModel
        case .year:
            return LGLocalizedString.postCategoryDetailCarYear
        }
    }
    
    func nextStep(postingType: RealEstatePostingType) -> PostingDetailStep? {
        switch self {
        case .price:
            return .propertyType
        case .propertyType:
            return .offerType
        case .offerType:
            return postingType == .standard ? .bedrooms : .rooms
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
