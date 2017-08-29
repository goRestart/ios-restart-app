//
//  Listing+Negotiable.swift
//  LetGo
//
//  Created by Eli Kohen on 07/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension Priceable {
    func priceString(freeModeAllowed: Bool) -> String {
        if freeModeAllowed && price.free {
            return LGLocalizedString.productFreePrice
        } else {
            return price.value > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
        }
    }
    
    func isNegotiable(freeModeAllowed: Bool) -> Bool {
        switch price {
        case .negotiable:
            return true
        case .free:
            return !freeModeAllowed
        case .normal(let value):
            return value == 0
        case .firmPrice:
            return false
        }
    }
}
