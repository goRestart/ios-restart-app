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
        var dataCount: Int = 0

        describe("last page") {
            context("only one requester, few items") {
                beforeEach {
                    let requester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    requester.generateItems(5)
                    sut = ProductListMultiRequester(requesters: [requester])

                    dataCount = 0
                    sut.currentIndex = 0
                    sut.retrieveFirstPage { result in
                        if let data = result.value {
                            dataCount = data.count
                        }
                    }
                }
                it("is last page") {
                    expect(sut.isLastPage(dataCount)).toEventually(equal(true))
                }
            }
            context("only one requester, lots of items") {
                beforeEach {
                    let requester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    requester.generateItems(50)
                    sut = ProductListMultiRequester(requesters: [requester])

                    dataCount = 0
                    sut.currentIndex = 0
                    sut.retrieveFirstPage { result in
                        if let data = result.value {
                            dataCount = data.count
                        }
                    }
                }
                it("is last page") {
                    expect(sut.isLastPage(dataCount)).toEventually(equal(false))
                }
                it("we're still using the first requester") {
                    expect(sut.currentIndex).toEventually(equal(0))
                }
            }
            context("more than one requester") {
                beforeEach {
                    let firstRequester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    firstRequester.generateItems(30)
                    let secondRequester = MockProductListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    secondRequester.generateItems(25)
                    sut = ProductListMultiRequester(requesters: [firstRequester, secondRequester])
                }
                context("get only 1st page of the multi requester") {
                    beforeEach {
                        dataCount = 0
                        sut.currentIndex = 0
                        sut.retrieveFirstPage { result in
                            if let data = result.value {
                                dataCount = data.count
                            }
                        }
                    }
                    it("not all items are consumed") {
                        expect(sut.isLastPage(dataCount)).toEventually(equal(false))
                    }
                    it("multi requester should still be using 1st requester") {
                        expect(sut.currentIndex).toEventually(equal(0))
                    }
                }
                context("reach the end of the multi requester") {
                    beforeEach {
                        dataCount = 0
                        sut.currentIndex = 0
                        sut.retrieveFirstPage { result in
                            if let data = result.value {
                                dataCount = data.count
                            }
                        }
                        sut.retrieveNextPage { result in
                            if let data = result.value {
                                dataCount += data.count
                            }
                        }
                        sut.retrieveNextPage { result in
                            if let data = result.value {
                                dataCount += data.count
                            }
                        }
                        sut.retrieveNextPage { result in
                            if let data = result.value {
                                dataCount += data.count
                            }
                        }
                    }
                    it("all items are consumed") {
                        expect(sut.isLastPage(dataCount)).toEventually(equal(true))
                    }
                    it("multi requester should be using 2nd requester") {
                        expect(sut.currentIndex).toEventually(equal(1))
                    }
                }
            }
        }
    }
}
