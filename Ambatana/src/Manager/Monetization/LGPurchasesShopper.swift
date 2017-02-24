//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Dídac on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import StoreKit

struct TransactionWithProductId {
    let transaction: SKPaymentTransaction
    let productId: String

    init(transaction: SKPaymentTransaction, productId: String) {
        self.transaction = transaction
        self.productId = productId
    }
}

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

    var receiptString: String? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptUrl) else { return nil }
        return receiptData.base64EncodedString()
    }

    var shopperState: ShopperState = .restoring

    fileprivate(set) var currentProductId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory
    private var monetizationRepository: MonetizationRepository
    private var myUserRepository: MyUserRepository
    fileprivate var keyValueStorage: KeyValueStorage

    weak var delegate: PurchasesShopperDelegate?
    private var isObservingPaymentsQueue: Bool = false

    fileprivate var productsDict: [String : [SKProduct]] = [:]

    fileprivate(set) var paymentProcessingProductId: String?
    fileprivate(set)var paymentProcessingPaymentId: String?

    override convenience init() {
        let factory = AppstoreProductsRequestFactory()
        let monetizationRepository = Core.monetizationRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(requestFactory: factory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository,
                  keyValueStorage: keyValueStorage)
    }

    init(requestFactory: PurchaseableProductsRequestFactory, monetizationRepository: MonetizationRepository,
         myUserRepository: MyUserRepository, keyValueStorage: KeyValueStorage) {
        self.monetizationRepository = monetizationRepository
        self.requestFactory = requestFactory
        self.productsRequest = requestFactory.generatePurchaseableProductsRequest([])
        self.myUserRepository = myUserRepository
        self.keyValueStorage = keyValueStorage
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
     Checks if the product has a bump up pending

     - parameter productId: ID of the listing to check
     */
    func productIsPayedButNotBumped(_ productId: String) -> Bool {
        let transactionsDict = keyValueStorage.userTransactionsProductsInfo

        let matchingProductIds = transactionsDict.filter {
            guard let transactionWithProductId = NSKeyedUnarchiver.unarchiveObject(with: $0.value) as?
                TransactionWithProductId else { return false }
            return transactionWithProductId.productId == productId
        }
        return matchingProductIds.count > 0
    }

    /**
     Request a payment to the appstore

     - parameter product: info of the product to purchase on the appstore
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

    func requestPricedBumpUpForProduct(_ productId: String) {
        let transactionsDict = keyValueStorage.userTransactionsProductsInfo

        let productIdsTransactions : [SKPaymentTransaction] = transactionsDict.flatMap {
            guard let transactionWithProductId = NSKeyedUnarchiver.unarchiveObject(with: $0.value) as?
                TransactionWithProductId else { return nil }
            if transactionWithProductId.productId == productId {
                return transactionWithProductId.transaction
            }
            return nil
        }

        guard productIdsTransactions.count > 0 else { return }
        guard let transaction = productIdsTransactions.first else { return }
        guard let receiptString = receiptString else { return }

        requestPricedBumpUpForProduct(productId: productId, receiptData: receiptString, transaction: transaction)
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
                SKPaymentQueue.default().finishTransaction(transaction)
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

                save(transaction: transaction, forProduct: paymentProcessingProductId)

                guard let receiptString = receiptString else { continue }
                guard let paymentProcessingProductId = paymentProcessingProductId else { continue }

                requestPricedBumpUpForProduct(productId: paymentProcessingProductId, receiptData: receiptString,
                                              transaction: transaction)
                shopperState = .restoring
            case .failed:
                print(transaction.error)
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
                print(transaction.error)
                delegate?.pricedBumpPaymentDidFail()
                queue.finishTransaction(transaction)
            default:
                logMessage(.debug, type: .monetization, message: "Unexpected transaction state")
            }
        }
    }

    fileprivate func save(transaction: SKPaymentTransaction, forProduct productId: String?) {
        guard let transactionId = transaction.transactionIdentifier, let productId = productId else { return }

        let transactionWithProductId = TransactionWithProductId(transaction: transaction, productId: productId)

        let encodedData = NSKeyedArchiver.archivedData(withRootObject: transactionWithProductId)

        var transactionsDict = keyValueStorage.userTransactionsProductsInfo
        let alreadySaved = transactionsDict.filter { $0.key == transactionId }.count == 0

        if !alreadySaved {
            transactionsDict[transactionId] = encodedData
            keyValueStorage.userTransactionsProductsInfo = transactionsDict
        }
    }

    fileprivate func productIdFor(transaction: SKPaymentTransaction) -> String? {
        guard let transactionId = transaction.transactionIdentifier else { return nil }
        guard let transactionData = keyValueStorage.userTransactionsProductsInfo[transactionId] else { return nil }
        guard let transactionWithProductId = NSKeyedUnarchiver.unarchiveObject(with: transactionData) as?
            TransactionWithProductId else { return nil }
        return transactionWithProductId.productId
    }

    fileprivate func remove(transaction transactionId: String?) {
        guard let transactionId = transactionId else { return }
        var transactionsDict = keyValueStorage.userTransactionsProductsInfo
        transactionsDict.removeValue(forKey: transactionId)
        keyValueStorage.userTransactionsProductsInfo = transactionsDict
    }
}
