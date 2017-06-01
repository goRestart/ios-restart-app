//
//  RateBuyersViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/05/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation


@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class RateBuyersViewModelSpec: BaseViewModelSpec {
    var navigatorReceivedRateBuyerCancel: Bool = false
    var navigatorReceivedRateBuyerFinished: Bool = false
    var navigatorReceivedFinishWithOutsideLetgo: Bool = false
    
    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        navigatorReceivedRateBuyerCancel = false
        navigatorReceivedRateBuyerFinished = false
        navigatorReceivedFinishWithOutsideLetgo = false
    }
    
    override func spec() {
        var sut: RateBuyersViewModel!
        var listingRepository: MockListingRepository!
        
        describe("RateBuyersViewModelSpec") {
            
            beforeEach {
                self.resetViewModelSpec()
                
                listingRepository = MockListingRepository()
                listingRepository.transactionResult = ListingTransactionResult(MockTransaction.makeMock())
                
                let buyers = MockUserListing.makeMocks(count: 5)
                let listingId = "123456789"
                
                sut = RateBuyersViewModel(buyers: buyers,
                                          listingId: listingId,
                                          sourceRateBuyers: nil,
                                          listingRepository: listingRepository)
                sut.navigator = self
                sut.delegate = self
            }
            
            describe("select sold outside letgo") {
                context("transaction succeeds") {
                    beforeEach {
                        listingRepository.transactionResult = ListingTransactionResult(value: MockTransaction.makeMock())
                        sut.notOnLetgoButtonPressed()
                    }
                    
                    it("calls show loading on delegate") {
                        expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    }
                    it("calls hide loading on delegate") {
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    it("calls navigator to finish outside letgo") {
                        expect(self.navigatorReceivedFinishWithOutsideLetgo).toEventually(beTrue())
                    }
                }
                
                context("transaction fails") {
                    beforeEach {
                        listingRepository.transactionResult = ListingTransactionResult(error: .tooManyRequests)
                        sut.notOnLetgoButtonPressed()
                    }
                    
                    it("calls show loading on delegate") {
                        expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    }
                    it("calls hide loading on delegate") {
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                }
            }
            
            describe("select sold in letgo") {
                context("transaction succeeds") {
                    beforeEach {
                        listingRepository.transactionResult = ListingTransactionResult(value: MockTransaction.makeMock())
                        sut.selectedBuyerAt(index: 0)
                    }
                    
                    it("calls show loading on delegate") {
                        expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    }
                    it("calls hide loading on delegate") {
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    it("calls navigator to finish in letgo") {
                        expect(self.navigatorReceivedRateBuyerFinished).toEventually(beTrue())
                    }
                }
                
                context("transaction fails") {
                    beforeEach {
                        listingRepository.transactionResult = ListingTransactionResult(error: .tooManyRequests)
                        sut.selectedBuyerAt(index: 0)
                    }
                    
                    it("calls show loading on delegate") {
                        expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    }
                    it("calls hide loading on delegate") {
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                }
            }
            
            describe("select cancel process") {
                beforeEach {
                    sut.closeButtonPressed()
                }
                
                it("calls navigator to cancel") {
                    expect(self.navigatorReceivedRateBuyerCancel) == true
                }
            }
        }
    }
}

extension RateBuyersViewModelSpec: RateBuyersViewModelDelegate {}

extension RateBuyersViewModelSpec: RateBuyersNavigator {
    func rateBuyersCancel() {
        navigatorReceivedRateBuyerCancel = true
    }
    func rateBuyersFinish(withUser: UserListing) {
        navigatorReceivedRateBuyerFinished = true
    }
    func rateBuyersFinishNotOnLetgo() {
        navigatorReceivedFinishWithOutsideLetgo = true
    }
}
