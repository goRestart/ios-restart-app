//
//  MockPurchaseableProduct.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation

struct MockPurchaseableProduct : PurchaseableProduct{
    var localizedDescription: String
    var localizedTitle: String
    var price: NSDecimalNumber
    var priceLocale: NSLocale
    var productIdentifier: String
    var downloadable: Bool
    var downloadContentLengths: [NSNumber]
    var downloadContentVersion: String

    init() {
        let localizedDescription = "Mock description"
        let localizedTitle = "Mock Title"
        let price = NSDecimalNumber(double: 1.99)
        let priceLocale = NSLocale.currentLocale()
        let productIdentifier = "MockId0000"
        let downloadable = false
        let downloadContentLengths: [NSNumber] = []
        let downloadContentVersion = ""
        self.init(localizedDescription: localizedDescription, localizedTitle: localizedTitle, price: price,
                  priceLocale: priceLocale, productIdentifier: productIdentifier, downloadable: downloadable,
                  downloadContentLengths: downloadContentLengths, downloadContentVersion: downloadContentVersion)
    }

    init(localizedDescription: String, localizedTitle: String, price: NSDecimalNumber, priceLocale: NSLocale,
         productIdentifier: String, downloadable: Bool, downloadContentLengths: [NSNumber], downloadContentVersion: String) {

        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.price = price
        self.priceLocale = priceLocale
        self.productIdentifier = productIdentifier
        self.downloadable = downloadable
        self.downloadContentLengths = downloadContentLengths
        self.downloadContentVersion = downloadContentVersion
    }
}
