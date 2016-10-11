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

        return price > 0 ? formattedPrice() :  LGLocalizedString.productNegotiablePrice
    }
}
