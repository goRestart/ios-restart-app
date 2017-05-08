//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Dídac on 29/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import StoreKit
import AdSupport
import AppsFlyerLib

enum PurchasesShopperState {
    case restoring
    case purchasing
}

protocol PurchasesShopperDelegate: class {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct])

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

    private var canMakePayments: Bool {
        return paymentQueue.canMakePayments
    }

    var purchasesShopperState: PurchasesShopperState = .restoring

    fileprivate(set) var currentRequestProductId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory
    private var monetizationRepository: MonetizationRepository
    private var myUserRepository: MyUserRepository
    private var installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorage
    private var receiptURLProvider: ReceiptURLProvider
    fileprivate var paymentQueue: PaymentEnqueuable
    fileprivate var appstoreProductsCache: [String : SKProduct] = [:]

    weak var delegate: PurchasesShopperDelegate?
    private var isObservingPaymentsQueue: Bool = false

    var numPendingTransactions: Int {
        return paymentQueue.transactions.count
    }

    var letgoProductsDict: [String : [SKProduct]] = [:]
    var paymentProcessingProductId: String?
    var paymentProcessingPaymentId: String?

    override convenience init() {
        let factory = AppstoreProductsRequestFactory()
        let monetizationRepository = Core.monetizationRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(requestFactory: factory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository,
                  installationRepository: installationRepository, keyValueStorage: keyValueStorage,
                  paymentQueue: SKPaymentQueue.default(), receiptURLProvider: Bundle.main)
    }

    convenience init(requestFactory: PurchaseableProductsRequestFactory,
                     monetizationRepository: MonetizationRepository,
                     myUserRepository: MyUserRepository,
                     installationRepository: InstallationRepository,
                     paymentQueue: PaymentEnqueuable,
                     receiptURLProvider: ReceiptURLProvider) {
        let keyValueStorage = KeyValueStorage.sharedInstance
        self.init(requestFactory: requestFactory, monetizationRepository: monetizationRepository, myUserRepository: myUserRepository,
                  installationRepository: installationRepository, keyValueStorage: keyValueStorage, paymentQueue: paymentQueue,
                  receiptURLProvider: receiptURLProvider)
    }

    init(requestFactory: PurchaseableProductsRequestFactory,
         monetizationRepository: MonetizationRepository,
         myUserRepository: MyUserRepository,
         installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorage,
         paymentQueue: PaymentEnqueuable,
         receiptURLProvider: ReceiptURLProvider) {
        self.monetizationRepository = monetizationRepository
        self.requestFactory = requestFactory
        self.productsRequest = requestFactory.generatePurchaseableProductsRequest([])
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.keyValueStorage = keyValueStorage
        self.receiptURLProvider = receiptURLProvider
        self.paymentQueue = paymentQueue
        super.init()
        productsRequest.delegate = self
        cleanCorruptedData()
    }

    // MARK: Public methods

    /**
     Sets itself as the payment transactions observer
     */
    func startObservingTransactions() {
        // guard to avoid adding the observer several times
        guard !isObservingPaymentsQueue && canMakePayments else { return }
        paymentQueue.add(self)
        isObservingPaymentsQueue = true
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
        guard productId != currentRequestProductId, canMakePayments else { return }

        // check cached products
        let alreadyChosenProducts = appstoreProductsCache.filter(keys: ids).map { $0.value }
        guard alreadyChosenProducts.isEmpty else {
            // if product has been previously requested, we don't repeat the request, so the banner loads faster
            letgoProductsDict[productId] = alreadyChosenProducts
            delegate?.shopperFinishedProductsRequestForProductId(productId, withProducts: alreadyChosenProducts)
            return
        }

        productsRequest.cancel()
        currentRequestProductId = productId
        productsRequest = requestFactory.generatePurchaseableProductsRequest(ids)
        productsRequest.delegate = self
        productsRequest.start()
    }

    /**
     Checks if the product has a bump up pending
     */
    func isBumpUpPending(forListingId listingId: String) -> Bool {
        let transactionsDict = keyValueStorage.userPendingTransactionsProductIds

        let matchingProductIds = transactionsDict.filter { $0.value == listingId }
        return matchingProductIds.count > 0 && numPendingTransactions > 0
    }

    /**
     Request a payment to the appstore
     */
    func requestPayment(forListingId listingId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        guard canMakePayments else { return }
        purchasesShopperState = .purchasing
        guard let appstoreProducts = letgoProductsDict[listingId],
              let appstoreChosenProduct = appstoreProduct as? SKProduct else { return }
        guard appstoreProducts.contains(appstoreChosenProduct) else { return }

        delegate?.pricedBumpDidStart()

        paymentProcessingProductId = listingId
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

    func requestFreeBumpUp(forListingId listingId: String, paymentItemId: String, shareNetwork: EventParameterShareNetwork) {
        delegate?.freeBumpDidStart()
        monetizationRepository.freeBump(forProduct: listingId, itemId: paymentItemId) { [weak self] result in
            if let _ = result.value {
                self?.delegate?.freeBumpDidSucceed(withNetwork: shareNetwork)
            } else if let _ = result.error {
                self?.delegate?.freeBumpDidFail(withNetwork: shareNetwork)
            }
        }
    }

    /**
     Method to request bumps already paid.  Transaction info is saved at keyValueStorage and in the payments queue
     */
    func requestPricedBumpUp(forListingId listingId: String) {
        guard canMakePayments else { return }
        guard let receiptString = receiptString else { return }

        let transactionsDict = keyValueStorage.userPendingTransactionsProductIds

        // get the product pending transaction ids saved in keyValueStorage
        let productPendingTransactionIds : [String] = transactionsDict.filter { $0.value == listingId }.map { $0.key }

        let pendingTransactions = paymentQueue.transactions
        guard productPendingTransactionIds.count > 0, pendingTransactions.count > 0 else { return }

        // get the pending SKPaymentTransactions of the product
        let pendingTransactionsForProductId = pendingTransactions.filter { transaction -> Bool in
            guard let transactionId = transaction.transactionIdentifier else { return false }
            return productPendingTransactionIds.contains(transactionId)
        }

        // try to restore the product pending bumps
        delegate?.freeBumpDidStart()

        for transaction in pendingTransactionsForProductId {
            requestPricedBumpUp(forListingId: listingId, receiptData: receiptString, transaction: transaction)
        }
    }

    /**
     Notify letgo API of the purchase

     - parameter listingId: letgo listing Id
     - parameter receiptData: post payment apple's receipt data
     - transaction: the app store transaction info
     */
    fileprivate func requestPricedBumpUp(forListingId listingId: String, receiptData: String, transaction: SKPaymentTransaction) {

        var price: String?
        var currency: String?
        if let appstoreProducts = letgoProductsDict[listingId], appstoreProducts.count > 0 {
            if let boughtProduct = appstoreProducts.first {
                price = String(describing: boughtProduct.price)
                currency = boughtProduct.priceLocale.currencyCode ?? ""
            }
        }

        let amplitudeId = myUserRepository.myUser?.emailOrId
        let appsflyerId = AppsFlyerTracker.shared().getAppsFlyerUID()
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let bundleId = Bundle.main.bundleIdentifier

        monetizationRepository.pricedBump(forProduct: listingId, receiptData: receiptData,
                                          itemId: transaction.payment.productIdentifier, itemPrice: price ?? "0",
                                          itemCurrency: currency ?? "", amplitudeId: amplitudeId, appsflyerId: appsflyerId,
                                          idfa: idfa, bundleId: bundleId) { [weak self] result in
            if let _ = result.value {
                self?.remove(transaction: transaction.transactionIdentifier)
                self?.paymentQueue.finishTransaction(transaction)
                self?.delegate?.pricedBumpDidSucceed()
            } else if let _ = result.error {
                self?.delegate?.pricedBumpDidFail()
            }
        }
    }

    private func cleanCorruptedData() {
        // Payments queue cleaning
        let savedTransactions = paymentQueue.transactions
        let savedTransactionIds = savedTransactions.flatMap { $0.transactionIdentifier }
        let savedTransactionsDict = keyValueStorage.userPendingTransactionsProductIds.filter(keys: savedTransactionIds)

        for transaction in savedTransactions {

            if let transactionId = transaction.transactionIdentifier, let _ = savedTransactionsDict[transactionId] {
                continue
            } else if transaction.transactionState != .purchasing {
                // "purchasing" transactions can't be finished
                paymentQueue.finishTransaction(transaction)
            }
        }

        // with clean payments queue, we do "keyValueStorage.userPendingTransactionsProductIds" cleaning
        let cleanTransactions = paymentQueue.transactions
        let cleanTransactionIds = cleanTransactions.flatMap { $0.transactionIdentifier }
        let cleanTransactionsDict = savedTransactionsDict.filter(keys: cleanTransactionIds)
        keyValueStorage.userPendingTransactionsProductIds = cleanTransactionsDict
    }
}


// MARK: - SKProductsRequestDelegate

extension LGPurchasesShopper: PurchaseableProductsRequestDelegate {
    func productsRequest(_ request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse) {

        guard let currentRequestProductId = currentRequestProductId else { return }

        let invalidIds = response.invalidProductIdentifiers
        if !invalidIds.isEmpty {
            let strInvalidIds: String = invalidIds.reduce("", { (a,b) in "\(a),\(b)"})
            let message = "Invalid ids: \(strInvalidIds)"
            logMessage(.error, type: [.monetization], message: message)
            report(AppReport.monetization(error: .invalidAppstoreProductIdentifiers), message: message)
        }

        let appstoreProducts = response.purchaseableProducts.flatMap { $0 as? SKProduct }

        // save valid products into appstore products cache
        appstoreProducts.forEach { product in
            appstoreProductsCache[product.productIdentifier] = product
        }
        letgoProductsDict[currentRequestProductId] = appstoreProducts
        delegate?.shopperFinishedProductsRequestForProductId(currentRequestProductId, withProducts: response.purchaseableProducts)
        self.currentRequestProductId = nil
    }

    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: Error) {
        // noo need to update any UI, we just don't show the banner
        self.currentRequestProductId = nil
        logMessage(.info, type: [.monetization], message: "Products request failed with error: \(error)")
    }
}


// MARK: SKPaymentTransactionObserver

extension LGPurchasesShopper: SKPaymentTransactionObserver {

    // Client should check state of transactions and finish as appropriate.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        switch purchasesShopperState {
        case .restoring:
            restorePaymentQueue(queue: queue, updatedTransactions: transactions)
        case .purchasing:
            purchasePaymentQueue(queue: queue, updatedTransactions: transactions)
        }
    }

    private func purchasePaymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                // this avoids duplicated transactions for a product
                remove(transaction: transaction.transactionIdentifier)
            case .deferred, .restored:
                /*
                 those status will never happen:
                 deferred: wait for an user action to confirm the purchase
                 restored: restore a previous purchase (non-consumable)
                 */
                continue
            case .purchased:
                purchasesShopperState = .restoring
                save(transaction: transaction, forProduct: paymentProcessingProductId)

                guard let receiptString = receiptString, let paymentProcessingProductId = paymentProcessingProductId else {
                    delegate?.pricedBumpDidFail()
                    continue
                }

                requestPricedBumpUp(forListingId: paymentProcessingProductId, receiptData: receiptString,
                                    transaction: transaction)
            case .failed:
                delegate?.pricedBumpPaymentDidFail()
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase failed with error: \(transaction.error?.localizedDescription)")
            }
        }
    }

    private func restorePaymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing, .deferred:
                continue
            case .purchased, .restored:
                let transactionProductId = productIdFor(transaction: transaction) ?? paymentProcessingProductId

                guard let productId = transactionProductId, let receiptString = receiptString else {
                    remove(transaction: transaction.transactionIdentifier)
                    queue.finishTransaction(transaction)
                    delegate?.pricedBumpDidFail()
                    continue
                }

                requestPricedBumpUp(forListingId: productId, receiptData: receiptString,
                                              transaction: transaction)
            case .failed:
                delegate?.pricedBumpPaymentDidFail()
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase restore failed with error: \(transaction.error?.localizedDescription)")
            }
        }
    }

    fileprivate func save(transaction: SKPaymentTransaction, forProduct productId: String?) {
        guard let transactionId = transaction.transactionIdentifier, let productId = productId else { return }

        var transactionsDict = keyValueStorage.userPendingTransactionsProductIds
        let alreadySaved = transactionsDict.filter { $0.key == transactionId }.count > 0

        if !alreadySaved {
            transactionsDict[transactionId] = productId
            keyValueStorage.userPendingTransactionsProductIds = transactionsDict
        }
    }

    fileprivate func productIdFor(transaction: SKPaymentTransaction) -> String? {
        guard let transactionId = transaction.transactionIdentifier else { return nil }
        return keyValueStorage.userPendingTransactionsProductIds[transactionId]
    }

    fileprivate func remove(transaction transactionId: String?) {
        guard let transactionId = transactionId else { return }
        var transactionsDict = keyValueStorage.userPendingTransactionsProductIds
        transactionsDict.removeValue(forKey: transactionId)
        keyValueStorage.userPendingTransactionsProductIds = transactionsDict
    }
}
