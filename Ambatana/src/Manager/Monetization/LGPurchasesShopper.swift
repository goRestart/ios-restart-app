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
    func shopperFailedProductsRequestForProductId(_ productId: String?, withError: Error)

    func freeBumpDidStart()
    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork)
    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork)

    func pricedBumpDidStart()
    func pricedBumpDidSucceed()
    func pricedBumpDidFail()
}

class LGPurchasesShopper: NSObject, PurchasesShopper {

    static let sharedInstance: PurchasesShopper = LGPurchasesShopper()

    fileprivate(set) var currentProductId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory
    private var monetizationRepository: MonetizationRepository
    private var myUserRepository: MyUserRepository

    weak var delegate: PurchasesShopperDelegate?
    private var isObservingPaymentsQueue: Bool = false

    fileprivate var productsDict: [String : [SKProduct]] = [:]

    fileprivate(set) var paymentProcessingProductId: String?
    fileprivate(set)var paymentProcessingPaymentId: String?

    override convenience init() {
        let factory = AppstoreProductsRequestFactory()
        let monetizationRepository = Core.monetizationRepository
        let myUserRepository = Core.myUserRepository
        self.init(requestFactory: factory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository)
    }

    init(requestFactory: PurchaseableProductsRequestFactory, monetizationRepository: MonetizationRepository,
         myUserRepository: MyUserRepository) {
        self.monetizationRepository = monetizationRepository
        self.requestFactory = requestFactory
        self.productsRequest = requestFactory.generatePurchaseableProductsRequest([])
        self.myUserRepository = myUserRepository
        super.init()
        productsRequest.delegate = self
    }

    // MARK: Public methods

    /**
     Sets itself as the payment transactions observer
     */
    func startObservingTransactions() {
        // guard to avoid adding the observer several times
        guard !isObservingPaymentsQueue else { return }
        SKPaymentQueue.default().add(self)
        isObservingPaymentsQueue = true
    }

    /**
     Removes itself as the payment transactions observer
     */
    func stopObservingTransactions() {
        guard isObservingPaymentsQueue else { return }
        SKPaymentQueue.default().remove(self)
        isObservingPaymentsQueue = false
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
    func requestPaymentForProduct(_ productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        guard let appstoreProducts = productsDict[productId],
              let appstoreChosenProduct = appstoreProduct as? SKProduct else { return }
        guard appstoreProducts.contains(appstoreChosenProduct) else { return }

        delegate?.pricedBumpDidStart()

        paymentProcessingProductId = productId
        paymentProcessingPaymentId = paymentItemId
        
        // request payment to appstore with "appstoreChosenProduct"
        let payment = SKMutablePayment(product: appstoreChosenProduct)
        if let myUserId = myUserRepository.myUser?.objectId {
            // add encrypted user id to help appstore prevent fraud
            let hashedUserName = myUserId.sha256()
            payment.applicationUsername = hashedUserName
        }

        SKPaymentQueue.default().add(payment)
    }

    func requestFreeBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, shareNetwork: EventParameterShareNetwork) {
        delegate?.freeBumpDidStart()
        monetizationRepository.freeBump(forProduct: productId, itemId: paymentItemId) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.freeBumpDidSucceed(withNetwork: shareNetwork)
            } else if let _ = result.error {
                self?.delegate?.freeBumpDidFail(withNetwork: shareNetwork)
            }
        }
    }

    /**
     Notify letgo API of the purchase

     - parameter productId: letgo product Id
     - parameter paymentItemId: letgo id for the purchased item
     - parameter receiptData: post payment apple's receipt data
     */
    func requestPricedBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, receiptData: String,
                                       transaction: SKPaymentTransaction) {

        monetizationRepository.pricedBump(forProduct: productId, receiptData: receiptData, itemId: paymentItemId) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.pricedBumpDidSucceed()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if let _ = result.error {
                self?.delegate?.pricedBumpDidFail()
            }
        }
    }
}


// MARK: - SKProductsRequestDelegate

extension LGPurchasesShopper: PurchaseableProductsRequestDelegate {
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
        self.currentProductId = nil
    }

    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: Error) {
        delegate?.shopperFailedProductsRequestForProductId(currentProductId, withError: error)
    }
}


// MARK: SKPaymentTransactionObserver

extension LGPurchasesShopper: SKPaymentTransactionObserver {

    // Client should check state of transactions and finish as appropriate.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/StoreKitGuide/Chapters/DeliverProduct.html#//apple_ref/doc/uid/TP40008267-CH5-SW4

        for transaction in transactions {

            print("🚧🚧🚧🚧🚧🚧🚧🚧🚧")
            print(transaction.transactionIdentifier)
            print(transaction.transactionState)
            print(transaction.transactionDate)
            print(transaction.payment.productIdentifier)
            print("-------------------")
            print(transaction.original?.transactionIdentifier)
            print(transaction.original?.transactionState)
            print(transaction.original?.transactionDate)
            print(transaction.original?.payment.productIdentifier)

            switch transaction.transactionState {
            case .purchasing, .deferred:
                print("purchasing or deferred")
                // save transaction id with paymentProcessingProductId & paymentProcessingPaymentId ?
            case .purchased:
                print("purchased")
                guard let receiptUrl = Bundle.main.appStoreReceiptURL,
                    let receiptData = try? Data(contentsOf: receiptUrl) else { return }
                let receiptString = receiptData.base64EncodedString()

                guard let paymentProcessingProductId = paymentProcessingProductId,
                    let paymentProcessingPaymentId = paymentProcessingPaymentId else { return }

                requestPricedBumpUpForProduct(productId: paymentProcessingProductId, withPaymentItemId: paymentProcessingPaymentId,
                                              receiptData: receiptString, transaction: transaction)
            case .restored:
                print("restored")
                guard let receiptUrl = Bundle.main.appStoreReceiptURL,
                    let receiptData = try? Data(contentsOf: receiptUrl) else { return }
                let receiptString = receiptData.base64EncodedString()

                // if we're trying to restore at app launch this gaurd will always fail
                // we should recover product & payment info.  Should be saved previously (at processing?)
                guard let paymentProcessingProductId = paymentProcessingProductId,
                    let paymentProcessingPaymentId = paymentProcessingPaymentId else { return }


                requestPricedBumpUpForProduct(productId: paymentProcessingProductId, withPaymentItemId: paymentProcessingPaymentId,
                                              receiptData: receiptString, transaction: transaction)
            case .failed:
                print("failed")
                print(transaction.error)
                delegate?.pricedBumpDidFail()
                queue.finishTransaction(transaction)
            default:
                logMessage(.debug, type: .monetization, message: "Unexpected transaction state")
            }
        }
    }

    // Sent when transactions are removed from the queue (via finishTransaction:).
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("🌎🌎🌎🌎🌎🌎🌎  removedTransactions")
    }

    // Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("🌎🌎🌎🌎🌎🌎🌎  restoreCompletedTransactionsFailedWithError")
    }

    // Sent when all transactions from the user's purchase history have successfully been added back to the queue.
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("🌎🌎🌎🌎🌎🌎🌎  paymentQueueRestoreCompletedTransactionsFinished")
    }
}
