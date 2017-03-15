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

    override func spec() {

        var sut: LGPurchasesShopper!
        var requestFactory: MockPurchaseableProductsRequestFactory!
        var monetizationRepository: MockMonetizationRepository!
        var myUserRepository: MockMyUserRepository!
        var paymentQueue: MockPaymentQueue!

        describe("PurchasesShopperSpec") {
            beforeEach {
                self.mockBumpResult = nil
                self.network = .notAvailable
                self.requestsFinished = []
                requestFactory = MockPurchaseableProductsRequestFactory()
                monetizationRepository = MockMonetizationRepository()
                myUserRepository = MockMyUserRepository()
                let mockReceiptURLProvider = MockReceiptURLProvider()
                paymentQueue = MockPaymentQueue()
                sut = LGPurchasesShopper(requestFactory: requestFactory, monetizationRepository: monetizationRepository,
                                         myUserRepository: myUserRepository, paymentQueue: paymentQueue,
                                         receiptURLProvider: mockReceiptURLProvider)
                sut.delegate = self
                sut.startObservingTransactions()
            }
            afterEach {
                sut.stopObservingTransactions()
            }
            context("productsRequestStartForProduct") {
                context("the device can't make purchases") {
                    beforeEach {
                        paymentQueue.canMakePayments = false
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                    }
                    it ("the delegate is never called") {
                        expect(self.requestsFinished).toEventually(equal([]))
                    }
                }
                context("on simple call") {
                    beforeEach {
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                    }
                    it ("the delegate is called with the requested productId") {
                        expect(self.requestsFinished).toEventually(equal(["a_product_id"]))
                    }
                }
                context("several consecutive quick calls, different product Ids") {
                    beforeEach {
                        requestFactory.responseDelay = 0.05
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                        sut.productsRequestStartForProduct("b_product_id", withIds: ["appstoreId2"])
                    }
                    it ("calls the delegate only for the last productId") {
                        expect(self.requestsFinished).toEventually(equal(["b_product_id"]))
                    }
                }
                context("several consecutive quick calls, repeating some product Ids") {
                    beforeEach {
                        requestFactory.responseDelay = 0.05
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                        sut.productsRequestStartForProduct("b_product_id", withIds: ["appstoreId2"])
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                    }
                    it ("calls the delegate only for the last productId") {
                        expect(self.requestsFinished).toEventually(equal(["a_product_id"]))
                    }
                }
                context("several consecutive spaced calls, different product Ids") {
                    beforeEach {
                        sut.productsRequestStartForProduct("a_product_id", withIds: ["appstoreId1"])
                        expect(self.requestsFinished).toEventually(equal(["a_product_id"]))
                        sut.productsRequestStartForProduct("b_product_id", withIds: ["appstoreId2"])
                    }
                    it ("calls the delegate for both productIds") {
                        expect(self.requestsFinished).toEventually(equal(["a_product_id", "b_product_id"]))
                    }
                }
            }
            context("free bump") {
                context("bump finishes successfully") {
                    beforeEach {
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                        sut.requestFreeBumpUpForProduct(productId: "a_product_id", withPaymentItemId: "payment_id_1",
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
                        sut.requestFreeBumpUpForProduct(productId: "a_product_id", withPaymentItemId: "payment_id_1",
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
                        sut.letgoProductsDict["product_id"] = [myAppstoreProduct]
                        sut.requestPaymentForProduct(productId: "product_id", appstoreProduct: myAppstoreProduct, paymentItemId: "payment_id")
                    }
                    it ("doesn't add a new payment to the queue") {
                        expect(sut.numPendingTransactions) == initialPendingPayments
                    }
                }
                context("the purchaseable product is available") {
                    beforeEach {
                        initialPendingPayments = sut.numPendingTransactions
                        let myAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "my_appstore_product_id")
                        sut.letgoProductsDict["product_id"] = [myAppstoreProduct]
                        sut.requestPaymentForProduct(productId: "product_id", appstoreProduct: myAppstoreProduct, paymentItemId: "payment_id")
                    }
                    it ("adds a new payment to the queue") {
                        expect(sut.numPendingTransactions) == initialPendingPayments + 1
                    }
                }
                context("the purchaseable product is unavailable") {
                    beforeEach {
                        initialPendingPayments = sut.numPendingTransactions
                        let myAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "my_appstore_product_id")
                        sut.letgoProductsDict["product_id"] = [myAppstoreProduct]
                        let unavailableAppstoreProduct = MyAppstoreProduct(myProductIdentifier: "unavailable_appstore_product_id")
                        sut.requestPaymentForProduct(productId: "product_id", appstoreProduct: unavailableAppstoreProduct, paymentItemId: "payment_id")
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
            context("product paid") {
                let transaction = MyPaymentTransaction(myTransactionIdentifier: "123123", myTransactionState: .purchased)
                context("new purchase") {
                    context("bump succeeds") {
                        beforeEach {
                            sut.paymentProcessingProductId = "product_id_success"
                            sut.paymentProcessingPaymentId = "payment_id_success"
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
                            sut.paymentProcessingProductId = "product_id_fail"
                            sut.paymentProcessingPaymentId = "payment_id_fail"
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
                context("restoring purchase") {
                    beforeEach {
                        sut.paymentProcessingProductId = "product_id_restore"
                        sut.paymentProcessingPaymentId = "payment_id_restore"
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

extension PurchasesShopperSpec: PurchasesShopperDelegate {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct]) {
        guard let id = productId else { return }
        self.requestsFinished.append(id)
    }

    func freeBumpDidStart() {
    }

    func freeBumpDidSucceed(withNetwork network: EventParameterShareNetwork) {
        self.network = network
        self.mockBumpResult = .success
    }

    func freeBumpDidFail(withNetwork network: EventParameterShareNetwork) {
        self.network = network
        self.mockBumpResult = .fail
    }

    func pricedBumpDidStart() {
    }

    func pricedBumpDidSucceed() {
        self.mockBumpResult = .success
    }

    func pricedBumpDidFail() {
        self.mockBumpResult = .fail
    }

    func pricedBumpPaymentDidFail() {
        self.mockBumpResult = .paymentFail
    }
}
