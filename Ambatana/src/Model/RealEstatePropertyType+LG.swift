//
//  RealEstatePropertyType.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension RealEstatePropertyType {
    var localizedString: String {
        switch self {
        case .apartment:
            return LGLocalizedString.realEstateTypePropertyApartment
        case .room:
            return LGLocalizedString.realEstateTypePropertyRoom
        case .house:
            return LGLocalizedString.realEstateTypePropertyHouse
        case .other:
            return LGLocalizedString.realEstateTypePropertyOthers
        case .commercial:
            return LGLocalizedString.realEstateTypePropertyCommercial
        case .flat:
            return LGLocalizedString.realEstateTypePropertyFlat
        case .land:
            return LGLocalizedString.realEstateTypePropertyLand
        case .villa:
            return LGLocalizedString.realEstateTypePropertyVilla
        }
    }
    
    var shortLocalizedString: String {
        switch self {
        case .apartment:
            return LGLocalizedString.realEstateTitleGeneratorPropertyTypeApartment
        case .room:
            return LGLocalizedString.realEstateTitleGeneratorPropertyTypeRoom
        case .house:
            return LGLocalizedString.realEstateTitleGeneratorPropertyTypeHouse
        case .other:
            return LGLocalizedString.realEstateTitleGeneratorPropertyTypeOther
        case .commercial:
            return LGLocalizedString.realEstateTitleGeneratorPropertyTypeCommercial
        case .flat:
            return LGLocalizedString.realEstateTypePropertyFlat
        case .land:
            return LGLocalizedString.realEstateTypePropertyLand
        case .villa:
            return LGLocalizedString.realEstateTypePropertyVilla
        }
    }
    
    static func allValues(postingFlowType: PostingFlowType) -> [RealEstatePropertyType] {
        return postingFlowType == .turkish ? [.flat, .villa, .commercial, .land, .other] : [.apartment, .room, .house, .commercial, .other]
    }
    
    func position(postingFlowType: PostingFlowType) -> Int? {
        return RealEstatePropertyType.allValues(postingFlowType: postingFlowType).index(of: self)
    }
}
