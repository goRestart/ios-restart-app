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
    
    var rateBuyerCancel: Bool! = false
    var rateBuyerFinished: Bool! = false
    var finishWithOutsideLetgo: Bool! = false
    var userId: String?
    
    override func spec() {
        
        var sut: RateBuyersViewModel!
        
        var listingRepository: MockListingRepository!
        
        describe("RateBuyersViewModelSpec") {
            
            beforeEach {
                listingRepository = MockListingRepository()
                listingRepository.transactionResult = ListingTransactionResult(MockTransaction.makeMock())
                
                let buyers = MockUserListing.makeMocks(count: 5)
                let listingId = "123456789"
                
                sut = RateBuyersViewModel(buyers: buyers, listingId: listingId, listingRepository: listingRepository)
                sut.navigator = self
            }
            
            context("select sold outside letgo") {
                beforeEach {
                    sut.notOnLetgoButtonPressed()
                }
                
                it("calls navigator to close coordinator") {
                    expect(self.finishWithOutsideLetgo) == true
                }
                it("has  no userId related") {
                    expect(self.userId).to(beNil())
                }
                
            }
            context("select sold in letgo") {
                beforeEach {
                    sut.selectedBuyerAt(index: 0)
                }
                
                it("finished rate buyer") {
                    expect(self.rateBuyerFinished) == true
                }
                it("has  no userId related") {
                    expect(self.userId).toNot(beNil())
                }
            }
            context("select cancel process") {
                beforeEach {
                    sut.closeButtonPressed()
                }
                it("calls navigator to close coordinator") {
                    expect(self.rateBuyerCancel) == true
                }
            }
        }
    }
}

extension RateBuyersViewModelSpec: RateBuyersNavigator {
    func rateBuyersCancel() {
        rateBuyerCancel = true
    }
    func rateBuyersFinish(withUser: UserListing) {
        rateBuyerFinished = true
        userId = withUser.objectId
    }
    func rateBuyersFinishNotOnLetgo() {
        finishWithOutsideLetgo = true
        userId = nil
    }
}
