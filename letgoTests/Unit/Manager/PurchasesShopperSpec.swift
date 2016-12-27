//
//  PurchasesShopperSpec.swift
//  LetGo
//
//  Created by Dídac on 20/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Quick
import Nimble

class PurchasesShopperSpec: QuickSpec {
    var requestsFinished: [String]!

    override func spec() {

        var sut: PurchasesShopper!
        var requestFactory: MockProductsRequestFactory!

        describe("PurchasesShopperSpec") {
            beforeEach {
                self.requestsFinished = []
                requestFactory = MockProductsRequestFactory()
                sut = PurchasesShopper(requestFactory: requestFactory)
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
        }
    }
}

extension PurchasesShopperSpec: PurchasesShopperDelegate {
    func shopperFinishedProductsRequestForProductId(productId: String?, withProducts products: [PurchaseableProduct]) {
        guard let id = productId else { return }
        self.requestsFinished.append(id)
    }

    func shopperFailedProductsRequestForProductId(productId: String?, withError: NSError) {

    }
}
