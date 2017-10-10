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
    func paymentDidSucceed(paymentId: String, transactionStatus: EventParameterTransactionStatus)
    func pricedBumpDidSucceed(type: BumpUpType, restoreRetriesCount: Int, transactionStatus: EventParameterTransactionStatus)
    func pricedBumpDidFail(type: BumpUpType, transactionStatus: EventParameterTransactionStatus)
    func pricedBumpPaymentDidFail(withReason reason: String?, transactionStatus: EventParameterTransactionStatus)

    func restoreBumpDidStart()
}

class LGPurchasesShopper: NSObject, PurchasesShopper {

    static let sharedInstance: PurchasesShopper = LGPurchasesShopper()

    fileprivate var receiptString: String? {
        guard let receiptUrl = receiptURLProvider.appStoreReceiptURL,
            let receiptData = try? Data(contentsOf: receiptUrl)
            else { return nil }
        return receiptData.base64EncodedString()
    }

    private var canMakePayments: Bool {
        return paymentQueue.canMakePayments
    }

    var purchasesShopperState: PurchasesShopperState = .restoring

    fileprivate(set) var currentRequestListingId: String?
    private var productsRequest: PurchaseableProductsRequest

    private var requestFactory: PurchaseableProductsRequestFactory
    private var monetizationRepository: MonetizationRepository
    private var myUserRepository: MyUserRepository
    private var installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorageable
    private var receiptURLProvider: ReceiptURLProvider
    fileprivate var paymentQueue: PaymentEnqueuable
    fileprivate var appstoreProductsCache: [String : SKProduct] = [:]

    weak var delegate: PurchasesShopperDelegate?
    private var isObservingPaymentsQueue: Bool = false

    var numPendingTransactions: Int {
        return paymentQueue.transactions.count
    }

    var letgoProductsDict: [String : [SKProduct]] = [:]
    var paymentProcessingListingId: String?
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
         keyValueStorage: KeyValueStorageable,
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
     Restore the failed paid bumps (payment was made, but bump failed)
     */
    func restoreFailedBumps() {
        let failedBumps = keyValueStorage.userFailedBumpsInfo

        for (listingId, bumpInfo) in failedBumps {
            guard let bumpDict = bumpInfo as? [String:String?],
                let bump = FailedBumpInfo(dictionary: bumpDict)
                else { continue }

            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: .restoring,
                                                                    transactionState: nil)
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump,
                                       transactionStatus: transactionStatus)
        }
    }

    /**
    Checks purchases available on appstore

     - parameter listingId: ID of the listing for wich will request the appstore products
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForListing(_ listingId: String, withIds ids: [String]) {
        guard listingId != currentRequestListingId, canMakePayments else { return }

        // check cached products
        let alreadyChosenProducts = appstoreProductsCache.filter(keys: ids).map { $0.value }
        guard alreadyChosenProducts.isEmpty else {
            // if product has been previously requested, we don't repeat the request, so the banner loads faster
            letgoProductsDict[listingId] = alreadyChosenProducts
            delegate?.shopperFinishedProductsRequestForListingId(listingId, withProducts: alreadyChosenProducts)
            return
        }

        productsRequest.cancel()
        currentRequestListingId = listingId
        productsRequest = requestFactory.generatePurchaseableProductsRequest(ids)
        productsRequest.delegate = self
        productsRequest.start()
    }

    /**
     Checks if the listing has a bump up pending
     */
    func isBumpUpPending(forListingId listingId: String) -> Bool {
        let failedBumpsDict = keyValueStorage.userFailedBumpsInfo

        guard let bumpDict = failedBumpsDict[listingId],
            let bump = FailedBumpInfo(dictionary: bumpDict) else { return false }

        if bump.numRetries <= Constants.maxRetriesForBumpUpRestore {
            return true
        } else {
            removeFromUserDefaults(transactionId: bump.transactionId)
            removeFromUserDefaultsBumpUpWithListingId(listingId: listingId)
            return false
        }
    }

    /**
     Request a payment to the appstore
     */
    func requestPayment(forListingId listingId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        guard canMakePayments else { return }
        guard let appstoreProducts = letgoProductsDict[listingId],
            let appstoreChosenProduct = appstoreProduct as? SKProduct,
            appstoreProducts.contains(appstoreChosenProduct)
            else { return }

        purchasesShopperState = .purchasing

        delegate?.pricedBumpDidStart()

        paymentProcessingListingId = listingId
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

        guard let bump = failedBumpInfoFor(listingId: listingId),
            let bumpTransactionId = bump.transactionId
            else { return }

        let pendingTransactions = paymentQueue.transactions
        // get the pending SKPaymentTransactions of the listing
        let pendingTransactionsForListingId = pendingTransactions.filter { transaction -> Bool in
            guard let transactionId = transaction.transactionIdentifier else { return false }
            return bumpTransactionId == transactionId
        }

        // try to restore the listing pending bumps
        delegate?.restoreBumpDidStart()


        if pendingTransactionsForListingId.count > 0 {
            // listing id still has SKPaymentTransactions in the paymentQueue
            // we need to pass the transaction to finish it in case
            for transaction in pendingTransactionsForListingId {
                let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: .restoring,
                                                                        transactionState: transaction.transactionState)

                requestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: .restore, currentBump: bump,
                                           transactionStatus: transactionStatus)
            }
        } else {
            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: .restoring,
                                                                    transactionState: nil)
            // listing id doesn't have SKPaymentTransactions in the paymentQueue
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump,
                                       transactionStatus: transactionStatus)
        }
    }

    /**
     User paid successfully, notify letgo API of the purchase.

     - parameter listingId: letgo listing Id
     - parameter receiptData: post payment apple's receipt data
     - parameter transaction: the app store transaction info
     - parameter type: the type of bump
     */
    fileprivate func requestPricedBumpUp(forListingId listingId: String,
                                         receiptData: String,
                                         transaction: SKPaymentTransaction,
                                         type: BumpUpType,
                                         transactionStatus: EventParameterTransactionStatus) {

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

        delegate?.paymentDidSucceed(paymentId: paymentId, transactionStatus: transactionStatus)

        let bump = FailedBumpInfo(listingId: listingId, transactionId: transaction.transactionIdentifier,
                                     paymentId: paymentId, receiptData: receiptData, itemId: transaction.payment.productIdentifier,
                                     itemPrice: price ?? "0", itemCurrency: currency ?? "", amplitudeId: amplitudeId,
                                     appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId, numRetries: 0)

        requestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: type, currentBump: bump, transactionStatus: transactionStatus)
    }

    /**
     Request a bump to letgo API of the purchase.  We pass all the info needed to validate & track the payment.
     Can come from a 1st purchase or from a restore.

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
                                            type: BumpUpType, currentBump: FailedBumpInfo,
                                            transactionStatus: EventParameterTransactionStatus) {

        guard currentBump.numRetries < Constants.maxRetriesForBumpUpRestore  else {
            removeFromUserDefaults(transactionId: currentBump.transactionId)
            removeFromUserDefaultsBumpUpWithListingId(listingId: listingId)
            return
        }

        var bump = currentBump
        let retryCount: Int
        switch type {
        case .priced:
            retryCount = Constants.maxRetriesForFirstTimeBumpUp
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
                                                guard let strongSelf = self else { return }
                                                if let _ = result.value {
                                                    strongSelf.finishTransaction(transaction: transaction,
                                                                            forListingId: listingId,
                                                                            withBumpUpInfo: bump)

                                                    strongSelf.delegate?.pricedBumpDidSucceed(type: type,
                                                                                         restoreRetriesCount: bump.numRetries,
                                                                                         transactionStatus: transactionStatus)
                                                } else if let error = result.error {
                                                    switch error {
                                                    case .serverError(code: let code):
                                                        if let code = code {
                                                            let bumpError = BumpFailedErrorCode(code: code)
                                                            if !bumpError.isUsersFault {
                                                                strongSelf.saveToUserDefaults(bumpUp: bump)
                                                            } else {
                                                                strongSelf.finishTransaction(transaction: transaction,
                                                                                        forListingId: listingId,
                                                                                        withBumpUpInfo: bump)
                                                            }
                                                        }
                                                    case .forbidden, .internalError, .network, .notFound, .tooManyRequests,
                                                         .unauthorized, .userNotVerified, .wsChatError:
                                                        strongSelf.saveToUserDefaults(bumpUp: bump)
                                                    }
                                                    strongSelf.delegate?.pricedBumpDidFail(type: type, transactionStatus: transactionStatus)
                                                }
        }
    }

    private func recursiveRequestBumpWithPaymentInfo(listingId: String,
                                                     transaction: SKPaymentTransaction?,
                                                     type: BumpUpType,
                                                     currentBump: FailedBumpInfo,
                                                     retryCount: Int,
                                                     previousResult: BumpResult?,
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
                                                                                                              previousResult: result,
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
                                                                                                      previousResult: result,
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
        let savedTransactionsDict = keyValueStorage.userPendingTransactionsListingIds.filter(keys: savedTransactionIds)

        for transaction in savedTransactions {

            if let transactionId = transaction.transactionIdentifier, let _ = savedTransactionsDict[transactionId] {
                continue
            } else if transaction.transactionState != .purchasing {
                // "purchasing" transactions can't be finished
                paymentQueue.finishTransaction(transaction)
            }
        }

        // with clean payments queue, we do "keyValueStorage.userPendingTransactionsListingIds" cleaning
        let cleanTransactions = paymentQueue.transactions
        let cleanTransactionIds = cleanTransactions.flatMap { $0.transactionIdentifier }
        let cleanTransactionsDict = savedTransactionsDict.filter(keys: cleanTransactionIds)
        keyValueStorage.userPendingTransactionsListingIds = cleanTransactionsDict
    }
}


// MARK: - SKProductsRequestDelegate

extension LGPurchasesShopper: PurchaseableProductsRequestDelegate {
    func productsRequest(_ request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse) {

        guard let currentRequestListingId = currentRequestListingId else { return }

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
        letgoProductsDict[currentRequestListingId] = appstoreProducts
        delegate?.shopperFinishedProductsRequestForListingId(currentRequestListingId, withProducts: response.purchaseableProducts)
        self.currentRequestListingId = nil
    }

    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: Error) {
        // noo need to update any UI, we just don't show the banner
        self.currentRequestListingId = nil
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
            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: purchasesShopperState,
                                                                    transactionState: transaction.transactionState)
            switch transaction.transactionState {
            case .purchasing:
                // this avoids duplicated transactions for a listing
                removeFromUserDefaults(transactionId: transaction.transactionIdentifier)
            case .deferred, .restored, .purchased:
                /*
                 deferred: wait for an user action to confirm the purchase
                 restored: restore a previous purchase (non-consumable)
                 those status should never happen:
                 */

                saveToUserDefaults(transaction: transaction, forListing: paymentProcessingListingId)

                guard let receiptString = receiptString, let paymentProcessingListingId = paymentProcessingListingId else {
                    delegate?.pricedBumpDidFail(type: .priced, transactionStatus: transactionStatus)
                    continue
                }

                requestPricedBumpUp(forListingId: paymentProcessingListingId, receiptData: receiptString,
                                    transaction: transaction, type: .priced, transactionStatus: transactionStatus)
                purchasesShopperState = .restoring
            case .failed:
                delegate?.pricedBumpPaymentDidFail(withReason: transaction.error?.localizedDescription,
                                                   transactionStatus: transactionStatus)
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase failed with error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
    }

    // Is not OUR restore (with a different banner) is apple's restore
    private func restorePaymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: purchasesShopperState,
                                                                    transactionState: transaction.transactionState)
            switch transaction.transactionState {
            case .purchasing:
                continue
            case .purchased, .restored, .deferred:
                let transactionListingId = listingIdFor(transaction: transaction) ?? paymentProcessingListingId

                guard let listingId = transactionListingId, let receiptString = receiptString else {
                    removeFromUserDefaults(transactionId: transaction.transactionIdentifier)
                    queue.finishTransaction(transaction)
                    delegate?.pricedBumpDidFail(type: .priced, transactionStatus: transactionStatus)
                    continue
                }
                requestPricedBumpUp(forListingId: listingId, receiptData: receiptString,
                                              transaction: transaction, type: .priced,
                                              transactionStatus: transactionStatus)
            case .failed:
                delegate?.pricedBumpPaymentDidFail(withReason: transaction.error?.localizedDescription,
                                                   transactionStatus: transactionStatus)
                queue.finishTransaction(transaction)
                logMessage(.info, type: [.monetization], message: "Purchase restore failed with error: \(String(describing: transaction.error?.localizedDescription))")
            }
        }
    }

    fileprivate func saveToUserDefaults(transaction: SKPaymentTransaction, forListing listingId: String?) {
        guard let transactionId = transaction.transactionIdentifier, let listingId = listingId else { return }

        var transactionsDict = keyValueStorage.userPendingTransactionsListingIds
        let alreadySaved = transactionsDict.filter { $0.key == transactionId }.count > 0

        if !alreadySaved {
            transactionsDict[transactionId] = listingId
            keyValueStorage.userPendingTransactionsListingIds = transactionsDict
        }
    }

    fileprivate func listingIdFor(transaction: SKPaymentTransaction) -> String? {
        guard let transactionId = transaction.transactionIdentifier else { return nil }
        return keyValueStorage.userPendingTransactionsListingIds[transactionId]
    }

    fileprivate func removeFromUserDefaults(transactionId: String?) {
        // remove transaction ids (apple's restore)
        guard let transactionId = transactionId else { return }
        var transactionsDict = keyValueStorage.userPendingTransactionsListingIds
        transactionsDict.removeValue(forKey: transactionId)
        keyValueStorage.userPendingTransactionsListingIds = transactionsDict
    }

    fileprivate func saveToUserDefaults(bumpUp bumpInfo: FailedBumpInfo?) {
        guard let bumpInfo = bumpInfo else { return }

        var failedBumpsDict = keyValueStorage.userFailedBumpsInfo
        failedBumpsDict[bumpInfo.listingId] = bumpInfo.dictionaryValue()
        keyValueStorage.userFailedBumpsInfo = failedBumpsDict
    }

    fileprivate func failedBumpInfoFor(listingId: String) -> FailedBumpInfo? {
        print(keyValueStorage)
        print(keyValueStorage.userFailedBumpsInfo)
        guard let dictionary = keyValueStorage.userFailedBumpsInfo[listingId] else { return nil }
        return FailedBumpInfo(dictionary: dictionary)
    }

    fileprivate func removeFromUserDefaultsBumpUpWithListingId(listingId: String) {
        // remove failed bump ups info (letgo's restore)
        var userFailedBumpsDict = keyValueStorage.userFailedBumpsInfo
        userFailedBumpsDict.removeValue(forKey: listingId)
        keyValueStorage.userFailedBumpsInfo = userFailedBumpsDict
    }

    fileprivate func finishTransaction(transaction: SKPaymentTransaction?,
                                       forListingId listingId: String,
                                       withBumpUpInfo bump: FailedBumpInfo) {
        removeFromUserDefaults(transactionId: transaction?.transactionIdentifier ?? bump.transactionId)
        removeFromUserDefaultsBumpUpWithListingId(listingId: listingId)
        if let transaction = transaction {
            paymentQueue.finishTransaction(transaction)
        }
    }
}

extension EventParameterTransactionStatus {
    init(purchasesShopperState: PurchasesShopperState, transactionState: SKPaymentTransactionState?) {
        guard let transactionState = transactionState else {
            switch purchasesShopperState {
            case .purchasing:
                self = .purchasingUnknown
            case .restoring:
                self = .restoringUnknown
            }
            return
        }
        switch purchasesShopperState {
        case .purchasing:
            switch transactionState {
            case .purchasing, .purchased:
                self = .purchasingPurchased
            case .deferred:
                self = .purchasingDeferred
            case .restored:
                self = .purchasingRestored
            case .failed:
                self = .purchasingFailed
            }
        case .restoring:
            switch transactionState {
            case .purchasing, .purchased:
                self = .restoringPurchased
            case .deferred:
                self = .restoringDeferred
            case .restored:
                self = .restoringRestored
            case .failed:
                self = .restoringFailed
            }
        }
    }
}
