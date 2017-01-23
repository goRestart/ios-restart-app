//
//  PurchasesShopperSpec.swift
//  LetGo
//
//  Created by Dídac on 20/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
@testable import LGCoreKit
import Quick
import Nimble
import Result

enum MockBumpResult {
    case success
    case fail
    case notDefined
}

class PurchasesShopperSpec: QuickSpec {
    var requestsFinished: [String]!
    var mockBumpResult: MockBumpResult!
    var network: EventParameterShareNetwork!

    override func spec() {

        var sut: PurchasesShopper!
        var requestFactory: MockProductsRequestFactory!
        var monetizationRepository: MockMonetizationRepository!

        describe("PurchasesShopperSpec") {
            beforeEach {
                self.requestsFinished = []
                requestFactory = MockProductsRequestFactory()
                monetizationRepository = MockMonetizationRepository()
                    sut = PurchasesShopper(requestFactory: requestFactory, monetizationRepository: monetizationRepository)
                sut.delegate = self
            }
            context("productsRequestStartForProduct") {
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
                        self.mockBumpResult = .notDefined
                        self.network = .notAvailable
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(value: Void())
                        sut.requestFreeBumpUpForProduct(productId: "a_product_id", withPaymentItemId: "payment_id_1",
                                                        shareNetwork: .email)
                        let _ = self.expectation(description: "Wait for network calls")
                        self.waitForExpectations(timeout: 0.2, handler: nil)
                    }
                    it ("bump request succeeds") {
                        expect(self.mockBumpResult) == .success
                    }
                    it ("network matches") {
                        expect(self.network) == .email
                    }
                }
                context("bump fails") {
                    beforeEach {
                        self.mockBumpResult = .notDefined
                        self.network = .notAvailable
                        monetizationRepository.bumpResult = Result<Void, RepositoryError>(error: .notFound)
                        sut.requestFreeBumpUpForProduct(productId: "a_product_id", withPaymentItemId: "payment_id_1",
                                                        shareNetwork: .email)
                        let _ = self.expectation(description: "Wait for network calls")
                        self.waitForExpectations(timeout: 0.2, handler: nil)
                    }
                    it ("bump request fails") {
                        expect(self.mockBumpResult) == .fail
                    }
                    it ("network matches") {
                        expect(self.network) == .email
                    }
                }
            }
        }
    }
}

extension PurchasesShopperSpec: PurchasesShopperDelegate {
    func shopperFinishedProductsRequestForProductId(_ productId: String?, withProducts products: [PurchaseableProduct]) {
        guard let id = productId else { return }
        self.requestsFinished.append(id)
    }

    func shopperFailedProductsRequestForProductId(_ productId: String?, withError: Error) {

    }

    func freeBumpStarted() {
    }

    func freeBumpSuccess(withNetwork network: EventParameterShareNetwork) {
        self.network = network
        self.mockBumpResult = .success
    }

    func freeBumpFailed(withNetwork network: EventParameterShareNetwork) {
        self.network = network
        self.mockBumpResult = .fail
    }
}
