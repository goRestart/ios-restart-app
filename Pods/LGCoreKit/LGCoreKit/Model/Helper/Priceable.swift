//
//  Priceable.swift
//  Pods
//
//  Created by Isaac Roldan on 27/4/16.
//
//

public protocol Priceable {
    var price: Double? { get }
    var currency: Currency { get }
}

extension Priceable {
    public func formattedPrice() -> String {
        let actualCurrencyCode = currency.code
        guard let actualPrice = price else { return "" }
        let formattedPrice = InternalCore.currencyHelper.formattedAmountWithCurrencyCode(actualCurrencyCode,
                                                                                         amount: actualPrice)
        return formattedPrice ?? "\(actualPrice)"
    }
}
