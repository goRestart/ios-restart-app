//
//  Priceable.swift
//  Pods
//
//  Created by Isaac Roldan on 27/4/16.
//
//

public protocol Priceable {
    var price: ProductPrice { get }
    var currency: Currency { get }
}

extension Priceable {
    public func formattedPrice() -> String {
        let actualCurrencyCode = currency.code
        let formattedPrice = InternalCore.currencyHelper.formattedAmountWithCurrencyCode(actualCurrencyCode,
                                                                                         amount: price.value)
        return formattedPrice ?? "\(price.value)"
    }
}
