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
    var value: String {
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
}

