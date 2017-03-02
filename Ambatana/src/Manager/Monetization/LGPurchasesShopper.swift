//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Dídac on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import StoreKit


enum ShopperState {
    case restoring
    case purchasing
}

protocol PurchasesShopperDelegate: class {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct])
    func shopperFailedProductsRequestForProductId(_ productId: String?, withError: Error)

    func freeBumpDidStart()
    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork)
    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork)

    func pricedBumpDidStart()
    func pricedBumpDidSucceed()
    func pricedBumpDidFail()
    func pricedBumpPaymentDidFail()
}

class LGPurchasesShopper: NSObject, PurchasesShopper {

    static let sharedInstance: PurchasesShopper = LGPurchasesShopper()

    fileprivate var receiptString: String? {
        guard let receiptUrl = receiptURLProvider.appStoreReceiptURL else { return nil }
        guard let receiptData = try? Data(contentsOf: receiptUrl) else { return nil }
        return receiptData.base64EncodedString()
    }

    var shopperState: ShopperState = .restoring

    fileprivate(set) var currentProductId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory
    private var monetizationRepository: MonetizationRepository
    private var myUserRepository: MyUserRepository
    fileprivate let keyValueStorage: KeyValueStorage
    private var receiptURLProvider: ReceiptURLProvider
    fileprivate var paymentQueue: SKPaymentQueue

    weak var delegate: PurchasesShopperDelegate?
    private var isObservingPaymentsQueue: Bool = false

    var numPendingTransactions: Int {
        return paymentQueue.transactions.count
    }
    var productsDict: [String : [SKProduct]] = [:]
    var paymentProcessingProductId: String?
    var paymentProcessingPaymentId: String?

    override convenience init() {
        let factory = AppstoreProductsRequestFactory()
        let monetizationRepository = Core.monetizationRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(requestFactory: factory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository,
                  keyValueStorage: keyValueStorage, paymentQueue: SKPaymentQueue.default(), receiptURLProvider: Bundle.main)
    }

    convenience init(requestFactory: PurchaseableProductsRequestFactory, monetizationRepository: MonetizationRepository,
                     myUserRepository: MyUserRepository, paymentQueue: SKPaymentQueue, receiptURLProvider: ReceiptURLProvider) {
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(requestFactory: requestFactory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository,
                  keyValueStorage: keyValueStorage, paymentQueue: SKPaymentQueue.default(), receiptURLProvider: receiptURLProvider)
    }

    init(requestFactory: PurchaseableProductsRequestFactory, monetizationRepository: MonetizationRepository,
         myUserRepository: MyUserRepository, keyValueStorage: KeyValueStorage, paymentQueue: SKPaymentQueue,
         receiptURLProvider: ReceiptURLProvider) {
        self.monetizationRepository = monetizationRepository
        self.requestFactory = requestFactory
        self.productsRequest = requestFactory.generatePurchaseableProductsRequest([])
        self.myUserRepository = myUserRepository
        self.keyValueStorage = keyValueStorage
        self.receiptURLProvider = receiptURLProvider
        self.paymentQueue = paymentQueue
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
        paymentQueue.add(self)
        isObservingPaymentsQueue = true

        // TODO: ⚠️⚠️⚠️ test Cleaning code - Delete before merging ⚠️⚠️⚠️
//        let transactions = paymentQueue.transactions
//        for transaction in transactions {
//            paymentQueue.finishTransaction(transaction)
//        }
    }

    /**
     Removes itself as the payment transactions observer
     */
    func stopObservingTransactions() {
        guard isObservingPaymentsQueue else { return }
        paymentQueue.remove(self)
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
     Checks if the product has a bump up pending

     - parameter productId: ID of the listing to check
     */
    func productIsPaidButNotBumped(_ productId: String) -> Bool {
        let transactionsDict = keyValueStorage.userTransactionsProductIds

        let matchingProductIds = transactionsDict.filter { $0.value == productId }
        return matchingProductIds.count > 0 && numPendingTransactions > 0
    }

    /**
     Request a payment to the appstore

     - parameter productId: letgo product ID
     - parameter appstoreProduct: info of the product to purchase on the appstore
     -
     */
    func requestPaymentForProduct(_ productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        shopperState = .purchasing
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

        paymentQueue.add(payment)
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
     Method to request bumps already paid.  Transaction info is saved at keyValueStorage and in the payments queue

     - parameter productId: letgo product Id
     */
    func requestPricedBumpUpForProduct(_ productId: String) {
        let transactionsDict = keyValueStorage.userTransactionsProductIds

        // get the product pending transaction ids saved in keyValueStorage
        let productPendingTransactionIds : [String] = transactionsDict.flatMap {
            if $0.value == productId {
                return $0.key
            }
            return nil
        }

        let pendingTransactions = paymentQueue.transactions
        guard productPendingTransactionIds.count > 0, pendingTransactions.count > 0 else { return }

        // get the pending SKPaymentTransactions of the product
        let pendingTransactionsForProductId = pendingTransactions.filter { transaction -> Bool in
            guard let transactionId = transaction.transactionIdentifier else { return false }
            return productPendingTransactionIds.contains(transactionId)
        }

        guard let receiptString = receiptString else { return }

        // try to restore the product pending bumps

        delegate?.freeBumpDidStart()

        for transaction in pendingTransactionsForProductId {
            requestPricedBumpUpForProduct(productId: productId, receiptData: receiptString, transaction: transaction)
        }
    }

    /**
     Notify letgo API of the purchase

     - parameter productId: letgo product Id
     - parameter receiptData: post payment apple's receipt data
     - transaction: the app store transaction info
     */
    fileprivate func requestPricedBumpUpForProduct(productId: String, receiptData: String, transaction: SKPaymentTransaction) {

        monetizationRepository.pricedBump(forProduct: productId, receiptData: receiptData,
                                          itemId: transaction.payment.productIdentifier) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.pricedBumpDidSucceed()
                self?.remove(transaction: transaction.transactionIdentifier)
                self?.paymentQueue.finishTransaction(transaction)
            } else if let _ = result.error {
                self?.delegate?.pricedBumpDidFail() // !!!!! ux for restored purchase!!!?!??!
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

        switch shopperState {
        case .restoring:
            restoringPaymentQueue(queue, updatedTransactions: transactions)
        case .purchasing:
            purchasingPaymentQueue(queue, updatedTransactions: transactions)
        }
    }

    private func purchasingPaymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                remove(transaction: transaction.transactionIdentifier)
            case .deferred, .restored:
                continue
            case .purchased:
                shopperState = .restoring
                save(transaction: transaction, forProduct: paymentProcessingProductId)

                guard let receiptString = receiptString else { continue }
                guard let paymentProcessingProductId = paymentProcessingProductId else { continue }

                requestPricedBumpUpForProduct(productId: paymentProcessingProductId, receiptData: receiptString,
                                              transaction: transaction)
            case .failed:
                delegate?.pricedBumpPaymentDidFail()
                queue.finishTransaction(transaction)
            default:
                logMessage(.debug, type: .monetization, message: "Unexpected transaction state")
            }
        }
    }

    private func restoringPaymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing, .deferred, .restored:
                continue
            case .purchased:
                let transactionProductId = productIdFor(transaction: transaction)

                guard let productId = transactionProductId else {
                    remove(transaction: transaction.transactionIdentifier)
                    queue.finishTransaction(transaction)
                    continue
                }
                guard let receiptString = receiptString else { continue }

                requestPricedBumpUpForProduct(productId: productId, receiptData: receiptString,
                                              transaction: transaction)
            case .failed:
                delegate?.pricedBumpPaymentDidFail()
                queue.finishTransaction(transaction)
            default:
                logMessage(.debug, type: .monetization, message: "Unexpected transaction state")
            }
        }
    }

    fileprivate func save(transaction: SKPaymentTransaction, forProduct productId: String?) {
        guard let transactionId = transaction.transactionIdentifier, let productId = productId else { return }

        var transactionsDict = keyValueStorage.userTransactionsProductIds
        let alreadySaved = transactionsDict.filter { $0.key == transactionId }.count > 0

        if !alreadySaved {
            transactionsDict[transactionId] = productId
            keyValueStorage.userTransactionsProductIds = transactionsDict
        }
    }

    fileprivate func productIdFor(transaction: SKPaymentTransaction) -> String? {
        guard let transactionId = transaction.transactionIdentifier else { return nil }
        return keyValueStorage.userTransactionsProductIds[transactionId]
    }

    fileprivate func remove(transaction transactionId: String?) {
        guard let transactionId = transactionId else { return }
        var transactionsDict = keyValueStorage.userTransactionsProductIds
        transactionsDict.removeValue(forKey: transactionId)
        keyValueStorage.userTransactionsProductIds = transactionsDict
    }
}
