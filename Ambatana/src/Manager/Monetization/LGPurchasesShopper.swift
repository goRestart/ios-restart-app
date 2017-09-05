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

struct FailedBumpInfo {

    static let listingIdKey = "listingId"
    static let transactionIdKey = "transactionId"
    static let paymentIdKey = "paymentId"
    static let receiptDataKey = "receiptData"
    static let itemIdKey = "itemId"
    static let itemPriceKey = "itemPrice"
    static let itemCurrencyKey = "itemCurrency"
    static let amplitudeIdKey = "amplitudeId"
    static let appsflyerIdKey = "appsflyerId"
    static let idfaKey = "idfa"
    static let bundleIdKey = "bundleId"
    static let numRetriesKey = "numRetries"

    let listingId: String
    let transactionId: String?
    let paymentId: String
    let receiptData: String
    let itemId: String
    let itemPrice: String
    let itemCurrency: String
    let amplitudeId: String?
    let appsflyerId: String?
    let idfa: String?
    let bundleId: String?
    let numRetries: Int

    init(listingId: String, transactionId: String?, paymentId: String, receiptData: String, itemId: String, itemPrice: String,
         itemCurrency: String, amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?, numRetries: Int) {
        self.listingId = listingId
        self.transactionId = transactionId
        self.paymentId = paymentId
        self.receiptData = receiptData
        self.itemId = itemId
        self.itemPrice = itemPrice
        self.itemCurrency = itemCurrency
        self.amplitudeId = amplitudeId
        self.appsflyerId = appsflyerId
        self.idfa = idfa
        self.bundleId = bundleId
        self.numRetries = numRetries
    }

    init?(dict: [String:String?]) {
        guard let listingId = dict[FailedBumpInfo.listingIdKey] as? String else { return nil }
        guard let paymentId = dict[FailedBumpInfo.paymentIdKey] as? String else { return nil }
        guard let receiptData = dict[FailedBumpInfo.receiptDataKey] as? String else { return nil }
        guard let itemId = dict[FailedBumpInfo.itemIdKey] as? String else { return nil }
        guard let itemPrice = dict[FailedBumpInfo.itemPriceKey] as? String else { return nil }
        guard let itemCurrency = dict[FailedBumpInfo.itemCurrencyKey] as? String else { return nil }
        guard let numRetriesString = dict[FailedBumpInfo.numRetriesKey] as? String, let numRetries = Int(numRetriesString) else { return nil }

        let transactionId = dict[FailedBumpInfo.transactionIdKey] as? String

        let amplitudeId = dict[FailedBumpInfo.amplitudeIdKey] as? String
        let appsflyerId = dict[FailedBumpInfo.appsflyerIdKey] as? String
        let idfa = dict[FailedBumpInfo.idfaKey] as? String
        let bundleId = dict[FailedBumpInfo.bundleIdKey] as? String

        self.init(listingId: listingId,
                  transactionId: transactionId,
                  paymentId: paymentId,
                  receiptData: receiptData,
                  itemId: itemId,
                  itemPrice: itemPrice,
                  itemCurrency: itemCurrency,
                  amplitudeId: amplitudeId,
                  appsflyerId: appsflyerId,
                  idfa: idfa,
                  bundleId: bundleId,
                  numRetries: numRetries)
    }

    func dictionaryValue() -> [String:String?] {
        var dict: [String:String] = [:]
        dict[FailedBumpInfo.listingIdKey] = listingId
        dict[FailedBumpInfo.transactionIdKey] = transactionId
        dict[FailedBumpInfo.paymentIdKey] = paymentId
        dict[FailedBumpInfo.receiptDataKey] = receiptData
        dict[FailedBumpInfo.itemIdKey] = itemId
        dict[FailedBumpInfo.itemPriceKey] = itemPrice
        dict[FailedBumpInfo.itemCurrencyKey] = itemCurrency
        dict[FailedBumpInfo.amplitudeIdKey] = amplitudeId
        dict[FailedBumpInfo.appsflyerIdKey] = appsflyerId
        dict[FailedBumpInfo.idfaKey] = idfa
        dict[FailedBumpInfo.bundleIdKey] = bundleId
        dict[FailedBumpInfo.numRetriesKey] = String(numRetries)
        return dict
    }

    func updatingNumRetries(newNumRetries: Int) -> FailedBumpInfo {
        return FailedBumpInfo(listingId: listingId, transactionId: transactionId,
                              paymentId: paymentId, receiptData: receiptData, itemId: itemId,
                              itemPrice: itemPrice, itemCurrency: itemCurrency, amplitudeId: amplitudeId,
                              appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId, numRetries: newNumRetries)
    }
}

enum BumpFailedErrorCode {
    case receiptInvalid
    case paymentAlreadyProcessed
    case notUsersFault

    init(code: Int) {
        switch code {
        case 400:
            self = .receiptInvalid
        case 409:
            self = .paymentAlreadyProcessed
        default:
            self = .notUsersFault
        }
    }

    var isUsersFault: Bool {
        switch self {
        case .notUsersFault:
            return false
        case .paymentAlreadyProcessed, .receiptInvalid:
            return true
        }
    }
}

enum PurchasesShopperState {
    case restoring
    case purchasing
}

protocol PurchasesShopperDelegate: class {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?, withProducts products: [PurchaseableProduct])

    func freeBumpDidStart()
    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork)
    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork)

    func pricedBumpDidStart()
    func paymentDidSucceed(paymentId: String)
    func pricedBumpDidSucceed(type: BumpUpType, restoreRetriesCount: Int)
    func pricedBumpDidFail(type: BumpUpType)
    func pricedBumpPaymentDidFail(withReason reason: String?)

    func restoreBumpDidStart()
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
        restoreFailedBumps()
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
    func productsRequestStartForListing(_ listingId: String, withIds ids: [String]) {
        guard listingId != currentRequestProductId, canMakePayments else { return }

        // check cached products
        let alreadyChosenProducts = appstoreProductsCache.filter(keys: ids).map { $0.value }
        guard alreadyChosenProducts.isEmpty else {
            // if product has been previously requested, we don't repeat the request, so the banner loads faster
            letgoProductsDict[listingId] = alreadyChosenProducts
            delegate?.shopperFinishedProductsRequestForListingId(listingId, withProducts: alreadyChosenProducts)
            return
        }

        productsRequest.cancel()
        currentRequestProductId = listingId
        productsRequest = requestFactory.generatePurchaseableProductsRequest(ids)
        productsRequest.delegate = self
        productsRequest.start()
    }

    /**
     Checks if the product has a bump up pending
     */
    func isBumpUpPending(forListingId listingId: String) -> Bool {
        let failedBumpsDict = keyValueStorage.userFailedBumpsInfo

        if let bumpDict = failedBumpsDict[listingId] as? [String:String?], let bump = FailedBumpInfo(dict: bumpDict) {
            if bump.numRetries <= Constants.maxRestoreRetries {
                return true
            } else {
                remove(transaction: bump.transactionId)
                removeFailedBumpInfoFor(listingId: listingId)
                return false
            }
        }
        return false
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
        monetizationRepository.freeBump(forListingId: listingId, itemId: paymentItemId) { [weak self] result in
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
    func restorePaidBumpUp(forListingId listingId: String) {
        guard canMakePayments else { return }

        guard var bump = failedBumpInfoFor(listingId: listingId), let bumpTransactionId = bump.transactionId else { return }

        let pendingTransactions = paymentQueue.transactions
        // get the pending SKPaymentTransactions of the product
        let pendingTransactionsForProductId = pendingTransactions.filter { transaction -> Bool in
            guard let transactionId = transaction.transactionIdentifier else { return false }
            return bumpTransactionId == transactionId
        }

        // try to restore the product pending bumps
        delegate?.restoreBumpDidStart()


        if pendingTransactionsForProductId.count > 0 {
            // listing id still has SKPaymentTransactions in the paymentQueue
            // we need to pas the transaction to finish it in case
            for transaction in pendingTransactionsForProductId {
                requestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: .restore, currentBump: bump)
            }
        } else {
            // listing id doesn't have SKPaymentTransactions in the paymentQueue
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump)
        }
    }

    /**
     User paid successfully, notify letgo API of the purchase.

     - parameter listingId: letgo listing Id
     - parameter receiptData: post payment apple's receipt data
     - parameter transaction: the app store transaction info
     - parameter type: the type of bump
     */
    fileprivate func requestPricedBumpUp(forListingId listingId: String, receiptData: String, transaction: SKPaymentTransaction, type: BumpUpType) {

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

        let paymentId = UUID().uuidString.lowercased()
        delegate?.paymentDidSucceed(paymentId: paymentId)

        let bump = FailedBumpInfo(listingId: listingId, transactionId: transaction.transactionIdentifier,
                                     paymentId: paymentId, receiptData: receiptData, itemId: transaction.payment.productIdentifier,
                                     itemPrice: price ?? "0", itemCurrency: currency ?? "", amplitudeId: amplitudeId,
                                     appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId, numRetries: 0)

        requestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: type, currentBump: bump)
    }

    /**
     Request a bump to letgo API of the purchase.  We pass all the info needed to validate & track the payment.
     CAn come form a 1st purchase or form a restore.

     - parameter listingId: letgo listing Id
     - parameter paymentId: unique id for the payment. Generated in the app
     - parameter receiptData: post payment apple's receipt data
     - parameter transaction: the app store transaction info
     - parameter itemPrice: price of the bump (used for revenue calc on BE)
     - parameter itemCurrency: currency of the bump (used for revenue calc on BE)
     - parameter amplitudeId: letgo listing Id (used for tracking in BE)
     - parameter appsflyerId: letgo listing Id (used for tracking in BE)
     - parameter idfa: letgo listing Id (used for tracking in BE)
     - parameter bundleId: the app bundle Id (used for tracking in BE)
     - parameter type: the type of bump
     */
    private func requestBumpWithPaymentInfo(listingId: String, transaction: SKPaymentTransaction?,
                                            type: BumpUpType, currentBump: FailedBumpInfo) {

        var bump = currentBump
        let retryCount: Int
        switch type {
        case .priced:
            retryCount = Constants.bumpNumRetries
        case .restore:
            retryCount = 1
            // increment the num of restore retries made at launch
            bump = bump.updatingNumRetries(newNumRetries: bump.numRetries+1)
        case .hidden, .free:
            // unlikely to happen
            retryCount = 1
        }

        recursiveRequestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: type, currentBump: bump,
                                            retryCount: retryCount, previousResult: nil) { [weak self] result in

                                                if let _ = result.value {
                                                    self?.remove(transaction: transaction?.transactionIdentifier ?? bump.transactionId)
                                                    self?.removeFailedBumpInfoFor(listingId: listingId)
                                                    if let transaction = transaction {
                                                        self?.paymentQueue.finishTransaction(transaction)
                                                    }
                                                    self?.delegate?.pricedBumpDidSucceed(type: type, restoreRetriesCount: bump.numRetries)
                                                } else if let error = result.error {
                                                    switch error {
                                                    case .serverError(code: let code):
                                                        if let code = code {
                                                            let bumpError = BumpFailedErrorCode(code: code)
                                                            if !bumpError.isUsersFault {
                                                                self?.save(bumpUp: bump)
                                                            } else {
                                                                self?.remove(transaction: transaction?.transactionIdentifier ?? bump.transactionId)
                                                                self?.removeFailedBumpInfoFor(listingId: listingId)
                                                                if let transaction = transaction {
                                                                    self?.paymentQueue.finishTransaction(transaction)
                                                                }
                                                            }
                                                        }
                                                    case .forbidden, .internalError, .network, .notFound, .tooManyRequests,
                                                         .unauthorized, .userNotVerified, .wsChatError:
                                                        self?.save(bumpUp: bump)
                                                    }
                                                    self?.delegate?.pricedBumpDidFail(type: type)
                                                }
        }


//        monetizationRepository.pricedBump(forListingId: listingId, paymentId: bump.paymentId, receiptData: bump.receiptData,
//                                          itemId: transaction?.payment.productIdentifier ?? bump.itemId,
//                                          itemPrice: bump.itemPrice, itemCurrency: bump.itemCurrency,
//                                          amplitudeId: bump.amplitudeId, appsflyerId: bump.appsflyerId,
//                                          idfa: bump.idfa, bundleId: bump.bundleId) { [weak self] result in
//
//                                            if let _ = result.value {
//                                                self?.remove(transaction: transaction?.transactionIdentifier ?? bump.transactionId)
//                                                self?.removeFailedBumpInfoFor(listingId: listingId)
//                                                if let transaction = transaction {
//                                                    self?.paymentQueue.finishTransaction(transaction)
//                                                }
//                                                self?.delegate?.pricedBumpDidSucceed(type: type)
//                                            } else if let error = result.error {
//                                                switch error {
//                                                case .serverError(code: let code):
//                                                    if let code = code {
//                                                        let bumpError = BumpFailedErrorCode(code: code)
//                                                        if !bumpError.isUsersFault {
//                                                            self?.save(bumpUp: bump)
//                                                        } else {
//                                                            self?.remove(transaction: transaction?.transactionIdentifier ?? bump.transactionId)
//                                                            self?.removeFailedBumpInfoFor(listingId: listingId)
//                                                            if let transaction = transaction {
//                                                                self?.paymentQueue.finishTransaction(transaction)
//                                                            }
//                                                        }
//                                                    }
//                                                case .forbidden, .internalError, .network, .notFound, .tooManyRequests,
//                                                     .unauthorized, .userNotVerified, .wsChatError:
//                                                    self?.save(bumpUp: bump)
//                                                }
//                                                self?.delegate?.pricedBumpDidFail(type: type)
//                                            }
//        }
    }

    private func recursiveRequestBumpWithPaymentInfo(listingId: String, transaction: SKPaymentTransaction?, type: BumpUpType,
                                                     currentBump: FailedBumpInfo, retryCount: Int, previousResult: BumpResult?,
                                                     completion: BumpCompletion?) {

        if let value = previousResult?.value {
            completion?(BumpResult(value: value))
        } else {
            if retryCount <= 0 {
                if let error = previousResult?.error {
                    completion?(BumpResult(error: error))
                } else {
                    completion?(BumpResult(error: .internalError(message: "Bump exceeded number of retries with unknown result")))
                }
            } else {

                monetizationRepository.pricedBump(forListingId: listingId, paymentId: currentBump.paymentId, receiptData: currentBump.receiptData,
                                                  itemId: transaction?.payment.productIdentifier ?? currentBump.itemId,
                                                  itemPrice: currentBump.itemPrice, itemCurrency: currentBump.itemCurrency,
                                                  amplitudeId: currentBump.amplitudeId, appsflyerId: currentBump.appsflyerId,
                                                  idfa: currentBump.idfa, bundleId: currentBump.bundleId) { [weak self] result in

                                                    if let value = result.value {
                                                        completion?(BumpResult(value: value))
                                                    } else if let error = result.error {
                                                        switch error {
                                                        case .serverError(code: let code):
                                                            if let code = code {
                                                                let bumpError = BumpFailedErrorCode(code: code)
                                                                if !bumpError.isUsersFault {
                                                                    self?.recursiveRequestBumpWithPaymentInfo(listingId: listingId,
                                                                                                              transaction: transaction,
                                                                                                              type: type,
                                                                                                              currentBump: currentBump,
                                                                                                              retryCount: retryCount - 1,
                                                                                                              previousResult: previousResult,
                                                                                                              completion: completion)
                                                                } else {
                                                                    completion?(BumpResult(error: error))
                                                                }
                                                            }
                                                        case .forbidden, .internalError, .network, .notFound, .tooManyRequests,
                                                             .unauthorized, .userNotVerified, .wsChatError:
                                                            self?.recursiveRequestBumpWithPaymentInfo(listingId: listingId,
                                                                                                      transaction: transaction,
                                                                                                      type: type,
                                                                                                      currentBump: currentBump,
                                                                                                      retryCount: retryCount - 1,
                                                                                                      previousResult: previousResult,
                                                                                                      completion: completion)
                                                        }
                                                    }
                }
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

    private func restoreFailedBumps() {
        let failedBumps = keyValueStorage.userFailedBumpsInfo

        for (listingId, bumpInfo) in failedBumps {
            guard let bumpDict = bumpInfo as? [String:String?] else { continue }
            guard let bump = FailedBumpInfo(dict: bumpDict) else { continue }
            if bump.numRetries >= Constants.maxRestoreRetries {
                remove(transaction: bump.transactionId)
                removeFailedBumpInfoFor(listingId: listingId)
                continue
            }
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump)
        }
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
        delegate?.shopperFinishedProductsRequestForListingId(currentRequestProductId, withProducts: response.purchaseableProducts)
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
                    delegate?.pricedBumpDidFail(type: .priced)
                    continue
                }

                requestPricedBumpUp(forListingId: paymentProcessingProductId, receiptData: receiptString,
                                    transaction: transaction, type: .priced)
            case .failed:
                delegate?.pricedBumpPaymentDidFail(withReason: transaction.error?.localizedDescription)
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase failed with error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
    }

    // Is not OUR restore (with a different banner) is apple's restore
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
                    delegate?.pricedBumpDidFail(type: .priced)
                    continue
                }
                requestPricedBumpUp(forListingId: productId, receiptData: receiptString,
                                              transaction: transaction, type: .priced)
            case .failed:
                delegate?.pricedBumpPaymentDidFail(withReason: transaction.error?.localizedDescription)
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase restore failed with error: \(String(describing: transaction.error?.localizedDescription))")
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
        // remove transaction ids (apple's restore)
        guard let transactionId = transactionId else { return }
        var transactionsDict = keyValueStorage.userPendingTransactionsProductIds
        transactionsDict.removeValue(forKey: transactionId)
        keyValueStorage.userPendingTransactionsProductIds = transactionsDict
    }


    fileprivate func save(bumpUp bumpInfo: FailedBumpInfo?) {
        guard let bumpInfo = bumpInfo else { return }

        var failedBumpsDict = keyValueStorage.userFailedBumpsInfo
        failedBumpsDict[bumpInfo.listingId] = bumpInfo.dictionaryValue()
        keyValueStorage.userFailedBumpsInfo = failedBumpsDict
    }

    fileprivate func failedBumpInfoFor(listingId: String) -> FailedBumpInfo? {
        guard let dictionary = keyValueStorage.userFailedBumpsInfo[listingId] as? [String:String?] else { return nil }
        return FailedBumpInfo(dict: dictionary)
    }

    fileprivate func removeFailedBumpInfoFor(listingId: String) {
        // remove failed bump ups info (letgo's restore)
        var userFailedBumpsDict = keyValueStorage.userFailedBumpsInfo
        userFailedBumpsDict.removeValue(forKey: listingId)
        keyValueStorage.userFailedBumpsInfo = userFailedBumpsDict
    }
}
