//
//  ProductListMultiRequesterSpec.swift
//  LetGo
//
//  Created by Dídac on 12/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class ProductListMultiRequesterSpec: QuickSpec {

    override func spec() {
        var sut: ProductListMultiRequester!

        describe("last page") {
            context("only one requester") {
                beforeEach {
                    let requester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    requester.generateItems(5)
                    sut = ProductListMultiRequester(requesters: [requester])
                }
                it("is last page") {
                    expect(sut.isLastPage(5)) == true
                }
            }
            context("more than one requester") {
                beforeEach {
                    let firstRequester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    firstRequester.generateItems(5)
                    let secondRequester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    secondRequester.generateItems(5)
                    sut = ProductListMultiRequester(requesters: [firstRequester, secondRequester])
                }
                context("first requester is the active requester") {
                    beforeEach {
                        sut.currentIndex = 0
                    }
                    it("we're on the 1st requester and isn't its last page") {
                        expect(sut.isLastPage(20)) == false
                    }
                    it("we're on the 1st requester and is its last page") {
                        expect(sut.isLastPage(5)) == false
                    }
                    it("index should increase after reaching a non-last requester last page") {
                        sut.isLastPage(5)
                        expect(sut.currentIndex) == 1
                    }
                }
                context("last requester is the active requester") {
                    beforeEach {
                        sut.currentIndex = 1
                    }
                    it("we're on the last requester and isn't its last page") {
                        expect(sut.isLastPage(20)) == false
                    }
                    it("we're on the last requester and is its last page") {
                        expect(sut.isLastPage(5)) == true
                    }
                }
            }
        }
    }
}
