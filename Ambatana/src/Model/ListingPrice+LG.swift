//
//  ListingPrice+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 30/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingPrice {
    func stringValue(currency: Currency, isFreeEnabled: Bool) -> String {
        if isFreeEnabled && isFree {
            return LGLocalizedString.productFreePrice
        } else {
            return value > 0 ? formattedPrice(currency: currency) :  LGLocalizedString.productNegotiablePrice
        }
    }
    
    private func formattedPrice(currency: Currency) -> String {
        let actualCurrencyCode = currency.code
        return Core.currencyHelper.formattedAmountWithCurrencyCode(actualCurrencyCode, amount: value)
    }
}


extension ListingPrice {
    func allowFreeFilters(freePostingModeAllowed: Bool) -> EventParameterBoolean {
        guard freePostingModeAllowed else { return .notAvailable }
        return isFree ? .trueParameter : .falseParameter
    }
}
