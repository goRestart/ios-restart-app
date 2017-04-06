//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension Priceable {
    func priceString() -> String {
        let priceValue = price.value
        
        // TODO: Injected in priceString the FeatureFlags or a value to check if it is enabled.
        if FeatureFlags.sharedInstance.freePostingModeAllowed && price.free {
            return LGLocalizedString.productFreePrice
        } else {
            return priceValue > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
        }
    }

    func priceString(freeModeAllowed: Bool) -> String {
        if freeModeAllowed && price.free {
            return LGLocalizedString.productFreePrice
        } else {
            return price.value > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
        }
    }
}
