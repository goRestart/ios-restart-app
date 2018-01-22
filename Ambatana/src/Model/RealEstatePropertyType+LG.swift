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
    
    static var allValues: [RealEstatePropertyType] {
        return [.apartment, .room, .house, .commercial, .other]
    }
    
    var position: Int {
        switch self {
        case .apartment:
            return 0
        case .room:
            return 1
        case .house:
            return 2
        case .commercial:
            return 3
        case .other:
            return 4
        case .flat:
            return 5
        case .land:
            return 6
        case .villa:
            return 7
        }
    }
}
