//
//  ListingListMultiRequesterSpec.swift
//  LetGo
//
//  Created by Dídac on 12/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class ListingListMultiRequesterSpec: QuickSpec {

    override func spec() {
        var sut: ListingListMultiRequester!
        var dataCount: Int = 0

        var result: ListingsRequesterResult!
        let completion: ListingsRequesterCompletion = { r in
            if let data = r.listingsResult.value {
                dataCount = data.count
            }
            result = r
        }

        describe("last page") {
            context("only one requester, few items") {
                beforeEach {
                    let requester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    requester.generateItems(5, allowDiscarded: true)
                    sut = ListingListMultiRequester(requesters: [requester])

                    dataCount = 0
                    sut.currentIndex = 0
                    sut.retrieveFirstPage { result in
                        if let data = result.listingsResult.value {
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
                    let requester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    requester.generateItems(50, allowDiscarded: true)
                    sut = ListingListMultiRequester(requesters: [requester])

                    dataCount = 0
                    sut.currentIndex = 0
                    sut.retrieveFirstPage { result in
                        if let data = result.listingsResult.value {
                            dataCount = data.count
                        }
                    }
                }
                it("is not last page") {
                    expect(sut.isLastPage(dataCount)).toEventually(equal(false))
                }
                it("we're still using the first requester") {
                    expect(sut.currentIndex).toEventually(equal(0))
                }
            }
            context("more than one requester") {
                beforeEach {
                    let firstRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    firstRequester.generateItems(30, allowDiscarded: true)
                    let secondRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                    secondRequester.generateItems(25, allowDiscarded: true)
                    sut = ListingListMultiRequester(requesters: [firstRequester, secondRequester])
                }
                context("get only 1st page of the multi requester") {
                    beforeEach {
                        dataCount = 0
                        sut.currentIndex = 0
                        sut.retrieveFirstPage(completion)
                        expect(result).toEventuallyNot(beNil())
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
                        result = nil

                        sut.retrieveFirstPage(completion)
                        expect(result).toEventuallyNot(beNil())
                        result = nil

                        sut.retrieveNextPage(completion)
                        expect(result).toEventuallyNot(beNil())
                        result = nil

                        sut.retrieveNextPage(completion)
                        expect(result).toEventuallyNot(beNil())
                        result = nil

                        sut.retrieveNextPage(completion)
                        expect(result).toEventuallyNot(beNil())
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
