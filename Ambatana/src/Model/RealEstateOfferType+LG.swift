//
//  RealEstateOfferType+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension RealEstateOfferType {
    var localizedString: String {
        switch self {
        case .rent:
            return LGLocalizedString.realEstateOfferTypeRent
        case .sale:
            return LGLocalizedString.realEstateOfferTypeSale
        }
    }
    
    static var allValues: [RealEstateOfferType] {
        return [.rent, .sale]
    }
    
    var position: Int {
        switch self {
        case .rent:
            return 0
        case .sale:
            return 1
        }
    }
}

