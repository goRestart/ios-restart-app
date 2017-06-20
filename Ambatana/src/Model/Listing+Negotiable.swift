//
//  Product+LG.swift
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
}
