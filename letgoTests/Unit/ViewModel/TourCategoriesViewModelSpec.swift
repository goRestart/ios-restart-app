//
//  TourCategoriesViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 17/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

class TourCategoriesViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        var sut: TourCategoriesViewModel!
        var tracker: MockTracker!
        
        describe("TourCategoriesViewModelSpec") {
            
            beforeEach {
                let taxonomies = [MockTaxonomy.makeMock(), MockTaxonomy.makeMock()]
                sut = TourCategoriesViewModel(tracker: tracker, taxonomies: taxonomies)
            }
            
            describe("initialization") {
                context("no items selected") {
                    it("categoriesSelected is 0") {
                    
                    }
                    it("categories is the same taxonomies passed")
                }
            }
            
            describe("initialization") {
                context("with 2 buyers") {
                    beforeEach {
                        let buyers = MockUserListing.makeMocks(count: 2)
                        sut = RateBuyersViewModel(buyers: buyers,
                                                  listingId: "123456789",
                                                  trackingInfo: trackingInfo,
                                                  listingRepository: listingRepository,
                                                  source: nil,
                                                  tracker: tracker)
                        sut.navigator = self
                        sut.delegate = self
                    }
                    
                    it("shows 2 buyers") {
                        expect(sut.buyersToShow) == 2
                    }
                    
                    it("does not show a more button") {
                        expect(sut.shouldShowSeeMoreOption) == false
                    }
                }
                
                context("with 3 buyers") {
                    beforeEach {
                        let buyers = MockUserListing.makeMocks(count: 3)
                        sut = RateBuyersViewModel(buyers: buyers,
                                                  listingId: "123456789",
                                                  trackingInfo: trackingInfo,
                                                  listingRepository: listingRepository,
                                                  source: nil,
                                                  tracker: tracker)
                        sut.navigator = self
                        sut.delegate = self
                    }
                    
                    it("shows 3 buyers") {
                        expect(sut.buyersToShow) == 3
                    }
                    
                    it("does not show a more button") {
                        expect(sut.shouldShowSeeMoreOption) == false
                    }
                }
                
                context("with 5 buyers") {
                    beforeEach {
                        let buyers = MockUserListing.makeMocks(count: 5)
                        sut = RateBuyersViewModel(buyers: buyers,
                                                  listingId: "123456789",
                                                  trackingInfo: trackingInfo,
                                                  listingRepository: listingRepository,
                                                  source: nil,
                                                  tracker: tracker)
                        sut.navigator = self
                        sut.delegate = self
                    }
                    
                    it("shows 3 buyers") {
                        expect(sut.buyersToShow) == 3
                    }
                    
                    it("shows a more button") {
                        expect(sut.shouldShowSeeMoreOption) == true
                    }
                }
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
                    it("tracks a product-detail-sold-outside-letgo event") {
                        expect(tracker.trackedEvents.map { $0.actualName }).toEventually(equal(["product-detail-sold-outside-letgo"]))
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

