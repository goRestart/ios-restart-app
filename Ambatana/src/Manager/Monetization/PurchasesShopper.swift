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
    func shopperFinishedProductsRequestWithProducts(products: [MonetizationProduct])

    // Payment
    func shopperPurchaseDidStart()
    func shopperPurchaseDidFinish()
    func shopperPurchaseDidFail()
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

    private var products: [MonetizationProduct]
    var productsRequest: SKProductsRequest

    weak var delegate: PurchasesShopperDelegate?

    override init() {
        self.products = []
        self.productsRequest = SKProductsRequest()
        super.init()
        productsRequest.delegate = self
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }

    /**
        Check products with itunes connect
     */
    func productsRequestStartwithIds(ids: [String]) {
        productsRequest = SKProductsRequest(productIdentifiers: Set(ids))
        productsRequest.delegate = self
        productsRequest.start()
    }

    func requestPaymentForProduct(product: MonetizationProduct) {
        let payment = SKMutablePayment(product: product.product)
        payment.quantity = 1
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }


    // Payment

    private func purchaseStartedForTransaction(transaction: SKPaymentTransaction) {
        delegate?.shopperPurchaseDidStart()
    }

    func purchaseFailedForTransaction(transaction: SKPaymentTransaction) {
        delegate?.shopperPurchaseDidFail()
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }

    func purchaseFinishedForTransaction(transaction: SKPaymentTransaction) {
        delegate?.shopperPurchaseDidFinish()
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
}


// MARK: - SKProductsRequestDelegate

extension PurchasesShopper: SKProductsRequestDelegate {
    dynamic func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {

        // TODO: manage "invalidProductIdentifiers"
//        for invalidIdentifier in response.invalidProductIdentifiers {
//            // Handle any invalid product identifiers. ( ? )
//        }

        products = response.products.flatMap { MonetizationProduct(product: $0) }

        delegate?.shopperFinishedProductsRequestWithProducts(products)
    }
}


// MARK: - SKPaymentTransactionObserver

extension PurchasesShopper: SKPaymentTransactionObserver {

    // https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/DeliverProduct.html#//apple_ref/doc/uid/TP40008267-CH5-SW4

    // Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchasing:
                // Transaction is being added to the server queue.
                // Update your UI to reflect the in-progress status, and wait to be called again.
                purchaseStartedForTransaction(transaction)
            case .Failed:
                // Transaction was cancelled or failed before being added to the server queue.
                // Use the value of the error property to present a message to the user. For a list of error constants, see SKErrorDomain in Store Kit Constants Reference.
                purchaseFailedForTransaction(transaction)
            case .Purchased:
                // Transaction is in queue, user has been charged.  Client should complete the transaction.
                // Provide the purchased functionality
                purchaseFinishedForTransaction(transaction)
            case .Restored, .Deferred:
                // - Restored: Transaction was restored from user's purchase history.  Client should complete the transaction.
                // Restore the previously purchased functionality
                // - Deferred: The transaction is in the queue, but its final status is pending external action.
                // Update your UI to reflect the deferred status, and wait to be called again.
                break
            }
        }
    }
}
