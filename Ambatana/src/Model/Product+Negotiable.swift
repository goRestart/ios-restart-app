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
        let priceValue = price.value ?? 0
        
        if FeatureFlags.freePostingMode.enabled && price.free {
            return LGLocalizedString.productFreePrice
        } else {
            return priceValue > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
        }
    }
}
