import LGComponents
import LGCoreKit
import StoreKit
import AdSupport
import AppsFlyerLib
import CommonCrypto

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

protocol BumpInfoRequesterDelegate: class {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?,
                                                    withProducts products: [PurchaseableProduct],
                                                    letgoItemId: String?,
                                                    storeProductId: String?,
                                                    maxCountdown: TimeInterval,
                                                    typePage: EventParameterTypePage?)
}

protocol PurchasesShopperDelegate: class {
    func freeBumpDidStart(typePage: EventParameterTypePage?)
    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork,
                            typePage: EventParameterTypePage?,
                            paymentId: String)
    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork, typePage: EventParameterTypePage?)

    func pricedBumpDidStart(typePage: EventParameterTypePage?, isBoost: Bool)
    func paymentDidSucceed(paymentId: String, transactionStatus: EventParameterTransactionStatus)
    func pricedBumpDidSucceed(type: BumpUpType,
                              restoreRetriesCount: Int,
                              transactionStatus: EventParameterTransactionStatus,
                              typePage: EventParameterTypePage?,
                              isBoost: Bool,
                              paymentId: String)
    func pricedBumpDidFail(type: BumpUpType,
                           transactionStatus: EventParameterTransactionStatus,
                           typePage: EventParameterTypePage?,
                           isBoost: Bool)
    func pricedBumpPaymentDidFail(withReason reason: String?,
                                  transactionStatus: EventParameterTransactionStatus)

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

    private(set) var currentListingId: String?
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
    weak var bumpInfoRequesterDelegate: BumpInfoRequesterDelegate?
    private var isObservingPaymentsQueue: Bool = false

    var numPendingTransactions: Int {
        return paymentQueue.transactions.count
    }

    var letgoProductsDict: [String : [SKProduct]] = [:]
    var paymentProcessingListingId: String?
    var paymentProcessingLetgoItemId: String?
    var paymentProcessingIsBoost: Bool = false
    var paymentProcessingMaxCountdown: TimeInterval = 0

    private var currentBumpLetgoItemId: String?
    private var currentBumpStoreProductId: String?
    private var currentBumpMaxCountdown: TimeInterval = 0
    private var currentBumpTypePage: EventParameterTypePage?

    private var recentBumpsCache: [String: (Date, TimeInterval)] = [:]
    static private let timeThresholdBetweenBumps: TimeInterval = 60


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
            guard let bump = FailedBumpInfo(dictionary: bumpInfo) else { continue }

            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: .restoring,
                                                                    transactionState: nil)
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump,
                                       transactionStatus: transactionStatus, isBoost: paymentProcessingIsBoost)
        }
    }

    /**
    Checks purchases available on appstore

     - parameter listingId: ID of the listing for wich will request the appstore products
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForListingId(_ listingId: String,
                                          letgoItemId: String,
                                          withIds ids: [String],
                                          maxCountdown: TimeInterval,
                                          typePage: EventParameterTypePage?) {
        guard listingId != currentListingId else { return }
        guard canMakePayments else { return }

        currentBumpLetgoItemId = letgoItemId
        currentBumpStoreProductId = ids.first
        currentBumpTypePage = typePage
        currentBumpMaxCountdown = maxCountdown

        // check cached products
        let alreadyChosenProducts = appstoreProductsCache.filter(keys: ids).map { $0.value }
        guard alreadyChosenProducts.isEmpty else {
            // if product has been previously requested, we don't repeat the request, so the banner loads faster
            letgoProductsDict[listingId] = alreadyChosenProducts
            bumpInfoRequesterDelegate?.shopperFinishedProductsRequestForListingId(listingId,
                                                                                  withProducts: alreadyChosenProducts,
                                                                                  letgoItemId: letgoItemId,
                                                                                  storeProductId: ids.first,
                                                                                  maxCountdown: maxCountdown,
                                                                                  typePage: typePage)
            return
        }

        productsRequest.cancel()
        currentListingId = listingId
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

        if bump.numRetries <= SharedConstants.maxRetriesForBumpUpRestore {
            return true
        } else {
            removeFromUserDefaults(transactionId: bump.transactionId)
            removeFromUserDefaultsBumpUpWithListingId(listingId: listingId)
            return false
        }
    }

    /**
     There's a delay from BE when giving bumpeable info immediately after a bump.
     We cache the latest bumps to avoid users bumping twice in a row.
     Checks if the listing was bumped recently, and if was bumped but a while ago, it removes it form the
     recent bumps cache
     */
    func timeSinceRecentBumpFor(listingId: String) -> (timeDifference: TimeInterval, maxCountdown: TimeInterval)? {
        guard let recentBumpInfo = recentBumpsCache[listingId] else { return nil }
        let recentBumpDate = recentBumpInfo.0
        let recentBumpMaxCountdown = recentBumpInfo.1
        let timeDifference = Date().timeIntervalSince1970 - recentBumpDate.timeIntervalSince1970
        guard LGPurchasesShopper.timeThresholdBetweenBumps < timeDifference else {
            return (timeDifference, recentBumpMaxCountdown)
        }
        recentBumpsCache[listingId] = nil
        return nil
    }

    /**
     Request a payment to the appstore
     */
    func requestPayment(forListingId listingId: String,
                        appstoreProduct: PurchaseableProduct,
                        letgoItemId: String,
                        isBoost: Bool,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?) {
        guard canMakePayments else { return }
        guard let appstoreProducts = letgoProductsDict[listingId],
            let appstoreChosenProduct = appstoreProduct as? SKProduct,
            appstoreProducts.contains(appstoreChosenProduct)
            else { return }

        purchasesShopperState = .purchasing
        currentBumpTypePage = typePage

        delegate?.pricedBumpDidStart(typePage: currentBumpTypePage, isBoost: isBoost)

        paymentProcessingListingId = listingId
        paymentProcessingLetgoItemId = letgoItemId
        paymentProcessingIsBoost = isBoost
        paymentProcessingMaxCountdown = maxCountdown
        
        // request payment to appstore with "appstoreChosenProduct"
        let payment = SKMutablePayment(product: appstoreChosenProduct)
        if let myUserId = myUserRepository.myUser?.objectId {
            // add encrypted user id to help appstore prevent fraud
            let hashedUserName = myUserId
            payment.applicationUsername = hashedUserName
        }

        paymentQueue.add(payment)
    }

    func requestFreeBumpUp(forListingId listingId: String, letgoItemId: String, shareNetwork: EventParameterShareNetwork) {
        delegate?.freeBumpDidStart(typePage: currentBumpTypePage)
        monetizationRepository.freeBump(forListingId: listingId, itemId: letgoItemId) { [weak self] result in
            if let _ = result.value {
                let paymentId = UUID().uuidString.lowercased()
                self?.delegate?.freeBumpDidSucceed(withNetwork: shareNetwork, typePage: self?.currentBumpTypePage, paymentId: paymentId)
            } else if let _ = result.error {
                self?.delegate?.freeBumpDidFail(withNetwork: shareNetwork, typePage: self?.currentBumpTypePage)
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
                                           transactionStatus: transactionStatus, isBoost: paymentProcessingIsBoost)
            }
        } else {
            let transactionStatus = EventParameterTransactionStatus(purchasesShopperState: .restoring,
                                                                    transactionState: nil)
            // listing id doesn't have SKPaymentTransactions in the paymentQueue
            requestBumpWithPaymentInfo(listingId: listingId, transaction: nil, type: .restore, currentBump: bump,
                                       transactionStatus: transactionStatus, isBoost: paymentProcessingIsBoost)
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
                                         transactionStatus: EventParameterTransactionStatus,
                                         isBoost: Bool,
                                         letgoItemId: String?,
                                         maxCountdown: TimeInterval) {

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
                                  paymentId: paymentId, letgoItemId: letgoItemId, receiptData: receiptData,
                                  itemId: transaction.payment.productIdentifier, itemPrice: price ?? "0",
                                  itemCurrency: currency ?? "", amplitudeId: amplitudeId,
                                  appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId, numRetries: 0,
                                  maxCountdown: maxCountdown)

        requestBumpWithPaymentInfo(listingId: listingId,
                                   transaction: transaction,
                                   type: type,
                                   currentBump: bump,
                                   transactionStatus: transactionStatus,
                                   isBoost: isBoost)
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
                                            transactionStatus: EventParameterTransactionStatus,
                                            isBoost: Bool) {

        guard currentBump.numRetries < SharedConstants.maxRetriesForBumpUpRestore  else {
            removeFromUserDefaults(transactionId: currentBump.transactionId)
            removeFromUserDefaultsBumpUpWithListingId(listingId: listingId)
            delegate?.pricedBumpDidFail(type: type,
                                        transactionStatus: transactionStatus,
                                        typePage: currentBumpTypePage,
                                        isBoost: isBoost)
            return
        }

        var bump = currentBump
        let retryCount: Int
        switch type {
        case .priced, .boost:
            retryCount = SharedConstants.maxRetriesForFirstTimeBumpUp
        case .restore:
            retryCount = 1
            // increment the num of restore retries made at launch
            bump = bump.updatingNumRetries(newNumRetries: bump.numRetries+1)
        case .hidden, .free:
            // unlikely to happen
            retryCount = 1
        case .loading:
            retryCount = 0
        }

        recursiveRequestBumpWithPaymentInfo(listingId: listingId, transaction: transaction, type: type, currentBump: bump,
                                            retryCount: retryCount, previousResult: nil) { [weak self] result in
                                                guard let strongSelf = self else { return }
                                                if let _ = result.value {
                                                    strongSelf.finishTransaction(transaction: transaction,
                                                                            forListingId: listingId,
                                                                            withBumpUpInfo: bump)

                                                    strongSelf.pricedBumpDidSucceed(type: type,
                                                                                    restoreRetriesCount: bump.numRetries,
                                                                                    transactionStatus: transactionStatus,
                                                                                    typePage: strongSelf.currentBumpTypePage,
                                                                                    isBoost: isBoost,
                                                                                    listingId: listingId,
                                                                                    maxCountdown: bump.maxCountdown,
                                                                                    paymentId: bump.paymentId)
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
                                                         .unauthorized, .userNotVerified, .wsChatError, .searchAlertError:
                                                        strongSelf.saveToUserDefaults(bumpUp: bump)
                                                    }
                                                    strongSelf.delegate?.pricedBumpDidFail(type: type,
                                                                                           transactionStatus: transactionStatus,
                                                                                           typePage: strongSelf.currentBumpTypePage,
                                                                                           isBoost: isBoost)
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

                monetizationRepository.pricedBump(forListingId: listingId,
                                                  paymentId: currentBump.paymentId,
                                                  letgoItemId: currentBump.letgoItemId,
                                                  receiptData: currentBump.receiptData,
                                                  itemId: transaction?.payment.productIdentifier ?? currentBump.itemId,
                                                  itemPrice: currentBump.itemPrice,
                                                  itemCurrency: currentBump.itemCurrency,
                                                  amplitudeId: currentBump.amplitudeId,
                                                  appsflyerId: currentBump.appsflyerId,
                                                  idfa: currentBump.idfa,
                                                  bundleId: currentBump.bundleId) { [weak self] result in

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
                                                             .unauthorized, .userNotVerified, .wsChatError, .searchAlertError:
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
        let savedTransactionIds = savedTransactions.compactMap { $0.transactionIdentifier }
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
        let cleanTransactionIds = cleanTransactions.compactMap { $0.transactionIdentifier }
        let cleanTransactionsDict = savedTransactionsDict.filter(keys: cleanTransactionIds)
        keyValueStorage.userPendingTransactionsListingIds = cleanTransactionsDict
    }

    private func pricedBumpDidSucceed(type: BumpUpType,
                                      restoreRetriesCount: Int,
                                      transactionStatus: EventParameterTransactionStatus,
                                      typePage: EventParameterTypePage?,
                                      isBoost: Bool,
                                      listingId: String,
                                      maxCountdown: TimeInterval,
                                      paymentId: String) {
        delegate?.pricedBumpDidSucceed(type: type,
                                       restoreRetriesCount: restoreRetriesCount,
                                       transactionStatus: transactionStatus,
                                       typePage: typePage,
                                       isBoost: isBoost,
                                       paymentId: paymentId)
        recentBumpsCache[listingId] = (Date(), maxCountdown)
    }
}


// MARK: - SKProductsRequestDelegate

extension LGPurchasesShopper: PurchaseableProductsRequestDelegate {
    func productsRequest(_ request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse) {

        guard let currentRequestListingId = currentListingId else { return }

        let invalidIds = response.invalidProductIdentifiers
        if !invalidIds.isEmpty {
            let strInvalidIds: String = invalidIds.reduce("", { (a,b) in "\(a),\(b)"})
            let message = "Invalid ids: \(strInvalidIds)"
            logMessage(.error, type: [.monetization], message: message)
            report(AppReport.monetization(error: .invalidAppstoreProductIdentifiers), message: message)
        }

        let appstoreProducts = response.purchaseableProducts.compactMap { $0 as? SKProduct }

        // save valid products into appstore products cache
        appstoreProducts.forEach { product in
            appstoreProductsCache[product.productIdentifier] = product
        }
        letgoProductsDict[currentRequestListingId] = appstoreProducts
        bumpInfoRequesterDelegate?.shopperFinishedProductsRequestForListingId(currentListingId,
                                                                              withProducts: response.purchaseableProducts,
                                                                              letgoItemId: currentBumpLetgoItemId,
                                                                              storeProductId: currentBumpStoreProductId,
                                                                              maxCountdown: currentBumpMaxCountdown,
                                                                              typePage: currentBumpTypePage)
        currentListingId = nil
    }

    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: Error) {
        currentListingId = nil
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
                    delegate?.pricedBumpDidFail(type: .priced,
                                                transactionStatus: transactionStatus,
                                                typePage: currentBumpTypePage,
                                                isBoost: paymentProcessingIsBoost)
                    continue
                }

                let bumpType: BumpUpType = paymentProcessingIsBoost ? .boost(boostBannerVisible: false) : .priced
                requestPricedBumpUp(forListingId: paymentProcessingListingId, receiptData: receiptString,
                                    transaction: transaction, type: bumpType, transactionStatus: transactionStatus,
                                    isBoost: paymentProcessingIsBoost, letgoItemId: paymentProcessingLetgoItemId,
                                    maxCountdown: paymentProcessingMaxCountdown)
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
                    delegate?.pricedBumpDidFail(type: .priced,
                                                transactionStatus: transactionStatus,
                                                typePage: currentBumpTypePage,
                                                isBoost: paymentProcessingIsBoost)
                    continue
                }
                let bumpType: BumpUpType = paymentProcessingIsBoost ? .boost(boostBannerVisible: false) : .priced
                requestPricedBumpUp(forListingId: listingId, receiptData: receiptString,
                                              transaction: transaction, type: bumpType,
                                              transactionStatus: transactionStatus,
                                              isBoost: paymentProcessingIsBoost,
                                              letgoItemId: paymentProcessingLetgoItemId,
                                              maxCountdown: paymentProcessingMaxCountdown)
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
