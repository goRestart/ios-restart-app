//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Dídac on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import StoreKit


protocol PurchasesShopperDelegate: class {
    func shopperFinishedProductsRequestForProductId(productId: String?, withProducts products: [MonetizationProduct])
}

struct MonetizationProduct {
    var id: String {
        return product.productIdentifier
    }
    var price: String {
        let priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = .Behavior10_4
        priceFormatter.numberStyle = .CurrencyStyle
        priceFormatter.locale = product.priceLocale
        return priceFormatter.stringFromNumber(product.price) ?? ""
    }
    var title: String {
        return product.localizedTitle
    }
    var description: String {
        return product.localizedDescription
    }
    private var product: SKProduct

    init(product: SKProduct) {
        self.product = product
    }
}


class PurchasesShopper: NSObject {

    static let sharedInstance: PurchasesShopper = PurchasesShopper()

    private var monetizationProducts: [MonetizationProduct]
    private var currentProductId: String?
    var productsRequest: SKProductsRequest

    weak var delegate: PurchasesShopperDelegate?

    override init() {
        self.monetizationProducts = []
        self.productsRequest = SKProductsRequest()
        super.init()
        productsRequest.delegate = self
    }

    /**
    Checks purchases available on appstore

     - parameter productId: ID of the listing for wich will request the appstore products
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForProduct(productId: String, withIds ids: [String]) {
        guard productId != currentProductId else { return }
        productsRequest.cancel()
        currentProductId = productId
        productsRequest = SKProductsRequest(productIdentifiers: Set(ids))
        productsRequest.delegate = self
        productsRequest.start()
    }

    /**
     Request a payment to the appstore

     - parameter product: info of the product to purchase on the appstore
     */
    func requestPaymentForProduct(product: MonetizationProduct) {
        // request payment to appstore
    }
}


// MARK: - SKProductsRequestDelegate

extension PurchasesShopper: SKProductsRequestDelegate {
    dynamic func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        // TODO: manage "invalidProductIdentifiers"
        monetizationProducts = response.products.flatMap { MonetizationProduct(product: $0) }
        delegate?.shopperFinishedProductsRequestForProductId(currentProductId, withProducts: monetizationProducts)
    }
}
