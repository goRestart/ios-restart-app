//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Dídac on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import StoreKit


protocol PurchasesShopperDelegate: class {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct])
    func shopperFailedProductsRequestForProductId(_ productId: String?, withError: NSError)
}

class PurchasesShopper: NSObject {

    static let sharedInstance: PurchasesShopper = PurchasesShopper()

    private(set) var currentProductId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory

    weak var delegate: PurchasesShopperDelegate?

    var productsDict: [String : [SKProduct]] = [:]

    override convenience init() {
        let factory = AppstoreProductsRequestFactory()
        self.init(requestFactory: factory)
    }

    init(requestFactory: PurchaseableProductsRequestFactory) {
        self.requestFactory = requestFactory
        self.productsRequest = requestFactory.generatePurchaseableProductsRequest([])
        super.init()
        productsRequest.delegate = self
    }

    /**
    Checks purchases available on appstore

     - parameter productId: ID of the listing for wich will request the appstore products
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForProduct(_ productId: String, withIds ids: [String]) {
        guard productId != currentProductId else { return }
        productsRequest.cancel()
        currentProductId = productId

        productsRequest = requestFactory.generatePurchaseableProductsRequest(ids)
        productsRequest.delegate = self
        productsRequest.start()
    }

    /**
     Request a payment to the appstore

     - parameter product: info of the product to purchase on the appstore
     */
    func requestPaymentForProduct(_ productId: String) {
        guard let appstoreProduct = productsDict[productId] else { return }
        // request payment to appstore with "appstoreProduct"

    }
}


// MARK: - SKProductsRequestDelegate

extension PurchasesShopper: PurchaseableProductsRequestDelegate {
    func productsRequest(_ request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse) {

        guard let currentProductId = currentProductId else { return }

        let invalidIds = response.invalidProductIdentifiers
        if !invalidIds.isEmpty {
            let strInvalidIds: String = invalidIds.reduce("", { (a,b) in "\(a),\(b)"})
            let message = "Invalid ids: \(strInvalidIds)"
            logMessage(.error, type: [.monetization], message: message)
            report(AppReport.monetization(error: .invalidAppstoreProductIdentifiers), message: message)
        }

        productsDict[currentProductId] = response.purchaseableProducts.flatMap { $0 as? SKProduct }
        delegate?.shopperFinishedProductsRequestForProductId(currentProductId, withProducts: response.purchaseableProducts)
    }

    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: NSError) {
        delegate?.shopperFailedProductsRequestForProductId(currentProductId, withError: error)
    }
}
