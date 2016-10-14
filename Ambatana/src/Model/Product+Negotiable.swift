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
        let price = self.price.value ?? 0

        switch FeatureFlags.freePostingMode {
        case .Disabled:
            return price > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
        case .SplitButton, .OneButton:
            if (self.price.free) {
                return LGLocalizedString.productFreePrice
            } else {
                return price > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
            }
        }
    }
}
