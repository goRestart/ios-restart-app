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
    func shopperFinishedProductsRequestWithProducts(products: [SKProduct])
}

class PurchasesShopper: NSObject {

    static let sharedInstance: PurchasesShopper = PurchasesShopper()

    private var products: [SKProduct]
    var productsRequest: SKProductsRequest

    weak var delegate: PurchasesShopperDelegate?

    override init() {
        self.products = []
        self.productsRequest = SKProductsRequest()
        super.init()
        productsRequest.delegate = self
    }

    /**
        Check products with itunes connect
     */
    func productsRequestStartwithIds(ids: [String]) {
        productsRequest = SKProductsRequest(productIdentifiers: Set(ids))
        productsRequest.delegate = self
        productsRequest.start()
    }

    func requestPaymentForProduct(product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        payment.quantity = 1
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
}


// MARK: - SKProductsRequestDelegate

extension PurchasesShopper: SKProductsRequestDelegate {
    dynamic func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {

        products = response.products

//        for invalidIdentifier in response.invalidProductIdentifiers {
//            // Handle any invalid product identifiers. ( ? )
//        }

        delegate?.shopperFinishedProductsRequestWithProducts(products)
    }
    
}


// MARK: - SKPaymentTransactionObserver

extension PurchasesShopper: SKPaymentTransactionObserver {

    // https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/DeliverProduct.html#//apple_ref/doc/uid/TP40008267-CH5-SW4

    // TODO: assign purchasesShopper as the observer in appdelegate

    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    }

    // Sent when transactions are removed from the queue (via finishTransaction:).
    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {

    }

    // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {

    }

    // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        
    }

    // Sent when the download state has changed.
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {

    }
}
