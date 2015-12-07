//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension Product {
    func priceString() -> String {
        let price = self.price ?? 0
        guard price > 0 else { return LGLocalizedString.productNegotiablePrice }

        return formattedPrice()
    }
}
