//
//  PurchaseableProduct.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


protocol PurchaseableProduct {
    var localizedDescription: String { get }
    var localizedTitle: String { get }
    var price: NSDecimalNumber { get }
    var priceLocale: NSLocale { get }
    var productIdentifier: String { get }
    var downloadable: Bool { get }
    var downloadContentLengths: [NSNumber] { get }
    var downloadContentVersion: String { get }
}

extension PurchaseableProduct {
    var formattedCurrencyPrice: String {
        let priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = .Behavior10_4
        priceFormatter.numberStyle = .CurrencyStyle
        priceFormatter.locale = priceLocale
        return priceFormatter.stringFromNumber(price) ?? ""
    }
}
