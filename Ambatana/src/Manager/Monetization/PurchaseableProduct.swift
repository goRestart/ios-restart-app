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
    var priceLocale: Locale { get }
    var productIdentifier: String { get }
    var downloadable: Bool { get }
    var downloadContentLengths: [NSNumber] { get }
    var downloadContentVersion: String { get }
}

extension PurchaseableProduct {
    var formattedCurrencyPrice: String {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = .behavior10_4
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = priceLocale
        return priceFormatter.string(from: price) ?? ""
    }
}
