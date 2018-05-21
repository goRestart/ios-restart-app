//
//  PurchasesShopperSpec.swift
//  LetGo
//
//  Created by Dídac on 20/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
@testable import LGCoreKit
import Quick
import Nimble
import Result
import StoreKit

enum MockBumpResult {
    case success
    case fail
    case paymentFail
}

class PurchasesShopperSpec: QuickSpec {
    var requestsFinished: [String]!
    var mockBumpResult: MockBumpResult?
    var network: EventParameterShareNetwork!
    var restoreRetriesCount: Int?

    override func spec() {

        var sut: LGPurchasesShopper!
        var requestFactory: MockPurchaseableProductsRequestFactory!
        var monetizationRepository: MockMonetizationRepository!
        var myUserRepository: MockMyUserRepository!
        var installationRepository: InstallationRepository!
        var paymentQueue: MockPaymentQueue!
        var keyValueStorage: KeyValueStorageable!

        describe("PurchasesShopperSpec") {
            beforeEach {
                self.mockBumpResult = nil
                self.network = .notAvailable
                self.requestsFinished = []
                requestFactory = MockPurchaseableProductsRequestFactory()
                monetizationRepository = MockMonetizationRepository()
                myUserRepository = MockMyUserRepository()
                installationRepository = MockInstallationRepository()
                keyValueStorage = MockKeyValueStorage()
                let userDefaultsUser = UserDefaultsUser()
                keyValueStorage.currentUserProperties = userDefaultsUser
                let mockReceiptURLProvider = MockReceiptURLProvider()
                paymentQueue = MockPaymentQueue()
                sut = LGPurchasesShopper(requestFactory: requestFactory, monetizationRepository: monetizationRepository,
                                         myUserRepository: myUserRepository, installationRepository: installationRepository,
                                         keyValueStorage: keyValueStorage, paymentQueue: paymentQueue,
                                         receiptURLProvider: mockReceiptURLProvider)
                sut.delegate = self
                sut.bumpInfoRequesterDelegate = self
                sut.startObservingTransactions()
            }
            afterEach {
                sut.stopObservingTransactions()
                keyValueStorage.userFailedBumpsInfo.removeAll()
            }
            context("productsRequestStartForListing") {
                context("the device can't make purchases") {
                    beforeEach {
                        paymentQueue.canMakePayments = false
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                    }
                    it ("the delegate is never called") {
                        expect(self.requestsFinished).toEventually(equal([]))
                    }
                }
                context("on simple call") {
                    beforeEach {
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                    }
                    it ("the delegate is called with the requested productId") {
                        expect(self.requestsFinished).toEventually(equal(["a_listing_id"]))
                    }
                }
                context("several consecutive quick calls, different product Ids") {
                    beforeEach {
                        requestFactory.responseDelay = 0.05
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                        sut.productsRequestStartForListingId("b_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId2"], maxCountdown: 1000, typePage: nil)
                    }
                    it ("calls the delegate only for the last productId") {
                        expect(self.requestsFinished).toEventually(equal(["b_listing_id"]))
                    }
                }
                context("several consecutive quick calls, repeating some product Ids") {
                    beforeEach {
                        requestFactory.responseDelay = 0.05
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                        sut.productsRequestStartForListingId("b_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId2"], maxCountdown: 1000, typePage: nil)
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                    }
                    it ("calls the delegate only for the last productId") {
                        expect(self.requestsFinished).toEventually(equal(["a_listing_id"]))
                    }
                }
                context("several consecutive spaced calls, different product Ids") {
                    beforeEach {
                        sut.productsRequestStartForListingId("a_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId1"], maxCountdown: 1000, typePage: nil)
                        expect(self.requestsFinished).toEventually(equal(["a_listing_id"]))
                        sut.productsRequestStartForListingId("b_listing_id", letgoItemId: "letgo_item_id",
                                                             withIds: ["appstoreId2"], maxCountdown: 1000, typePage: nil)
                    }
                    it ("calls the delegate for both productIds") {
                        expect(self.requestsFinished).toEventually(equal(["a_listing_id", "b_listing_id"]))
                    }
                }
            }
            context("free bump") {
                context("bump finishes successfully") {
                    beforeEach {
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                        sut.requestFreeBumpUp(forListingId: "a_listing_id", letgoItemId: "letgo_item_id_1",
                                              shareNetwork: .email)
                        expect(self.mockBumpResult).toEventuallyNot(beNil())
                    }
                    it ("bump request succeeds") {
                        expect(self.mockBumpResult) == .success
                    }
                    it ("network matches") {
                        expect(self.network) == .email
                    }
                }
                context("free bump fails") {
                    beforeEach {
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                        sut.requestFreeBumpUp(forListingId: "a_listing_id", letgoItemId: "letgo_item_id_1",
                                              shareNetwork: .email)
                        expect(self.mockBumpResult).toEventuallyNot(beNil())
                    }
                    it ("bump request fails") {
                        expect(self.mockBumpResult) == .fail
                    }
                    it ("network matches") {
                        expect(self.network) == .email
                    }
                }
            }
            context ("request payment") {
                var initialPendingPayments: Int = 0
                beforeEach {
                    initialPendingPayments = 0
                }
                context("the device can't make purchases") {
                    beforeEach {
                        paymentQueue.canMakePayments = false
                        initialPendingPayments = sut.numPendingTransactions
                        let myAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "my_appstore_product_id")
                        sut.letgoProductsDict["listing_id"] = [myAppstoreProduct]
                        sut.requestPayment(forListingId: "listing_id",
                                           appstoreProduct: myAppstoreProduct,
                                           letgoItemId: "letgo_item_id",
                                           isBoost: false,
                                           maxCountdown: 1000)
                    }
                    it ("doesn't add a new payment to the queue") {
                        expect(sut.numPendingTransactions) == initialPendingPayments
                    }
                }
                context("the purchaseable product is available") {
                    beforeEach {
                        initialPendingPayments = sut.numPendingTransactions
                        let myAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "my_appstore_product_id")
                        sut.letgoProductsDict["listing_id"] = [myAppstoreProduct]
                        sut.requestPayment(forListingId: "listing_id",
                                           appstoreProduct: myAppstoreProduct,
                                           letgoItemId: "letgo_item_id",
                                           isBoost: false,
                                           maxCountdown: 1000)
                    }
                    it ("adds a new payment to the queue") {
                        expect(sut.numPendingTransactions) == initialPendingPayments + 1
                    }
                }
                context("the purchaseable product is unavailable") {
                    beforeEach {
                        initialPendingPayments = sut.numPendingTransactions
                        let myAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "my_appstore_product_id")
                        sut.letgoProductsDict["listing_id"] = [myAppstoreProduct]
                        let unavailableAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "unavailable_appstore_product_id")
                        sut.requestPayment(forListingId: "listing_id",
                                           appstoreProduct: unavailableAppstoreProduct,
                                           letgoItemId: "letgo_item_id",
                                           isBoost: false,
                                           maxCountdown: 1000)
                    }
                    it ("doesn't add a new payment to the queue") {
                        expect(sut.numPendingTransactions) == initialPendingPayments
                    }
                }
            }
            context("product payment failed") {
                beforeEach {
                    let transaction = MyPaymentTransaction(myTransactionIdentifier: "123123", myTransactionState: .failed)
                    sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])
                    expect(self.mockBumpResult).toEventuallyNot(beNil())
                }
                it ("bump result payment fails") {
                    expect(self.mockBumpResult) == .paymentFail
                }

            }
            context("bump paid") {
                let transaction = MyPaymentTransaction(myTransactionIdentifier: "123123", myTransactionState: .purchased)
                context("new purchase") {
                    context("bump succeeds") {
                        beforeEach {
                            sut.paymentProcessingListingId = "listing_id_success"
                            sut.paymentProcessingLetgoItemId = "letgo_item_id_success"
                            transaction.myTransactionIdentifier = "purchase_bump_ok"
                            sut.purchasesShopperState = .purchasing
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                            sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])
                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it ("bump request succeeds") {
                            expect(self.mockBumpResult) == .success
                        }
                    }
                    context("bump fails") {
                        beforeEach {
                            sut.paymentProcessingListingId = "listing_id_fail"
                            sut.paymentProcessingLetgoItemId = "letgo_item_id_fail"
                            transaction.myTransactionIdentifier = "purchase_bump_fail"
                            sut.purchasesShopperState = .purchasing
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                            sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])
                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it ("bump request fails") {
                            expect(self.mockBumpResult) == .fail
                        }
                    }
                }
                context("restoring purchase immediately, there are payment transactions in the queue") {
                    beforeEach {
                        sut.paymentProcessingListingId = "listing_id_restore"
                        sut.paymentProcessingLetgoItemId = "letgo_item_id_restore"
                        transaction.myTransactionIdentifier = "restore_bump"
                        // purchase works, bump fails, so it's stored
                        sut.purchasesShopperState = .purchasing
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                        sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])

                        expect(self.mockBumpResult).toEventuallyNot(beNil())
                    }
                    it("failure") {
                        expect(self.mockBumpResult) == .fail
                    }
                    context("bump succeeds") {
                        beforeEach {
                            self.mockBumpResult = nil
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                            sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])

                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it ("bump request succeeds") {
                            expect(self.mockBumpResult) == .success
                        }
                    }
                    context("bump fails") {
                        beforeEach {
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                            sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])

                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it ("bump request fails") {
                            expect(self.mockBumpResult) == .fail
                        }
                    }
                }
                context("restoring purchase after app relaunch, there are NO payment transactions in the queue") {
                    var currentBump: FailedBumpInfo!
                    beforeEach {
                        currentBump = FailedBumpInfo(listingId: "listing_id_1", transactionId: "restore_bump",
                                                     paymentId: "listing_id_restore", letgoItemId: "letgo_item_id_restore",
                                                     receiptData: "receipt_data", itemId: "payment_id_restore",
                                                     itemPrice: "1.99", itemCurrency: "$", amplitudeId: nil,
                                                     appsflyerId: nil, idfa: nil, bundleId: nil, numRetries: 5,
                                                     maxCountdown: 80000)

                        var failedBumpsDict: [String:Any] = [:]
                        failedBumpsDict[currentBump.listingId] = currentBump.dictionaryValue()
                        keyValueStorage.userFailedBumpsInfo = failedBumpsDict as! [String : [String : String?]]
                    }
                    context("restore fails") {
                        beforeEach {
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                            sut.restorePaidBumpUp(forListingId: "listing_id_1")
                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it("user defaults still has the bump saved") {
                            let bump = keyValueStorage.userFailedBumpsInfo["listing_id_1"]
                            expect(bump).toNot(beNil())
                        }
                        it("the bump retries count has incremented") {
                            let bumpDict = keyValueStorage.userFailedBumpsInfo["listing_id_1"]!
                            let bump = FailedBumpInfo(dictionary: bumpDict)
                            expect(bump!.numRetries) == 6
                        }
                    }
                    context("restore fails for the 20th time") {
                        beforeEach {
                            currentBump = currentBump.updatingNumRetries(newNumRetries: 20)
                            var failedBumpsDict: [String:Any] = [:]
                            failedBumpsDict[currentBump.listingId] = currentBump.dictionaryValue()
                            keyValueStorage.userFailedBumpsInfo = failedBumpsDict as! [String : [String : String?]]

                            sut.restorePaidBumpUp(forListingId: "listing_id_1")
                        }
                        it("user defaults doesn't have the bump saved anymore") {
                            let bump = keyValueStorage.userFailedBumpsInfo["listing_id_1"]
                            expect(bump).to(beNil())
                        }
                    }
                    context("restore succeeds") {
                        beforeEach {
                            monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                            sut .restorePaidBumpUp(forListingId: "listing_id_1")
                            expect(self.mockBumpResult).toEventuallyNot(beNil())
                        }
                        it("user defaults doesn't have the bump saved anymore") {
                            let bump = keyValueStorage.userFailedBumpsInfo["listing_id_1"]
                            expect(bump).to(beNil())
                        }
                    }
                }
            }
            context("recent bumps check") {
                let transaction = MyPaymentTransaction(myTransactionIdentifier: "123123", myTransactionState: .purchased)
                context("bump succeeds") {
                    beforeEach {
                        sut.paymentProcessingListingId = "listing_id_recent_check_ok"
                        sut.paymentProcessingLetgoItemId = "letgo_item_id_success"
                        sut.paymentProcessingMaxCountdown = 1000
                        transaction.myTransactionIdentifier = "purchase_bump_ok"
                        sut.purchasesShopperState = .purchasing
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                        sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])
                        expect(self.mockBumpResult).toEventuallyNot(beNil())
                    }
                    it ("bump request succeeds") {
                        expect(self.mockBumpResult) == .success
                    }
                    it("recent bump info is not nil") {
                        expect(sut.timeSinceRecentBumpFor(listingId: "listing_id_recent_check_ok")).notTo(beNil())
                    }
                    it ("time since last bump for listing id is bigger than 0") {
                        expect(sut.timeSinceRecentBumpFor(listingId: "listing_id_recent_check_ok")!.timeDifference) > 0
                    }
                    it ("max countdown of bump for listing id is 1000") {
                        expect(sut.timeSinceRecentBumpFor(listingId: "listing_id_recent_check_ok")!.maxCountdown) == 1000
                    }
                }
                context("bump fails") {
                    beforeEach {
                        sut.paymentProcessingListingId = "listing_id_recent_check_fail"
                        sut.paymentProcessingLetgoItemId = "letgo_item_id_fail"
                        transaction.myTransactionIdentifier = "purchase_bump_fail"
                        sut.purchasesShopperState = .purchasing
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                        sut.paymentQueue(SKPaymentQueue.default(), updatedTransactions: [transaction])
                        expect(self.mockBumpResult).toEventuallyNot(beNil())
                    }
                    it ("bump request fails") {
                        expect(self.mockBumpResult) == .fail
                    }
                    it ("recent bump info is nil") {
                        expect(sut.timeSinceRecentBumpFor(listingId: "listing_id_recent_check_fail")).to(beNil())
                    }
                }
            }
        }
    }
}

class MyPaymentTransaction: SKPaymentTransaction {
    var myTransactionIdentifier: String?
    var myTransactionState: SKPaymentTransactionState!

    override var transactionIdentifier: String? {
        return myTransactionIdentifier
    }

    override var transactionState: SKPaymentTransactionState {
        return myTransactionState
    }

    init(myTransactionIdentifier: String, myTransactionState: SKPaymentTransactionState) {
        self.myTransactionIdentifier = myTransactionIdentifier
        self.myTransactionState = myTransactionState
    }
}

class MyAppstoreProduct: SKProduct {
    var myProductIdentifier: String

    override var productIdentifier: String {
        return myProductIdentifier
    }

    init(myProductIdentifier: String) {
        self.myProductIdentifier = myProductIdentifier
    }
}

extension PurchasesShopperSpec: BumpInfoRequesterDelegate {
    func shopperFinishedProductsRequestForListingId(_ listingId: String?,
                                                    withProducts products: [PurchaseableProduct],
                                                    letgoItemId: String?,
                                                    storeProductId: String?,
                                                    maxCountdown: TimeInterval,
                                                    typePage: EventParameterTypePage?) {
        guard let id = listingId else { return }
        self.requestsFinished.append(id)
    }
}

extension PurchasesShopperSpec: PurchasesShopperDelegate {

    func freeBumpDidStart(typePage: EventParameterTypePage?) {
    }

    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork, typePage: EventParameterTypePage?, paymentId: String) {
        self.network = network
        self.mockBumpResult = .success
    }

    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork, typePage: EventParameterTypePage?) {
        self.network = network
        self.mockBumpResult = .fail
    }

    func pricedBumpDidStart(typePage: EventParameterTypePage?, isBoost: Bool) {
    }

    func paymentDidSucceed(paymentId: String, transactionStatus: EventParameterTransactionStatus) {
    }

    func pricedBumpDidSucceed(type: BumpUpType,
                              restoreRetriesCount: Int,
                              transactionStatus: EventParameterTransactionStatus,
                              typePage: EventParameterTypePage?,
                              isBoost: Bool,
                              paymentId: String) {
        self.mockBumpResult = .success
        self.restoreRetriesCount = restoreRetriesCount
    }

    func pricedBumpDidFail(type: BumpUpType,
                           transactionStatus: EventParameterTransactionStatus,
                           typePage: EventParameterTypePage?,
                           isBoost: Bool) {
        self.mockBumpResult = .fail
    }

    func pricedBumpPaymentDidFail(withReason: String?, transactionStatus: EventParameterTransactionStatus) {
        self.mockBumpResult = .paymentFail
    }

    func restoreBumpDidStart() {
    }
}
