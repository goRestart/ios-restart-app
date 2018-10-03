@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

final class ListingListViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ListingListViewModel!
        
        var dataDelegate: SpyListingListViewModelDataDelegate!
        var featureFlags: MockFeatureFlags!
        var tracker: Tracker!
        
        
        // Init VM with requester
        describe("init view model with requester containing 33 products") {
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithRequester(33)
                    sut.retrieveListings()
                }
                
                it("receives 33 products") {
                    expect(dataDelegate.count).toEventually(equal(33))
                }
                it("returns the last used requester type as the requester passed in") {
                    expect(sut.listingListRequester?.isEqual(toRequester: sut.listingListRequester!)).to(beTrue())
                }
            }
        }
        
        describe("init view model with requester containing 0 product") {
            
            beforeEach {
                sut = makeSutWithRequester(0)
            }
            
            describe("retrieve listing") {
                beforeEach {
                    sut.retrieveListings()
                }
                
                it("receives 0 products") {
                    expect(dataDelegate.count).toEventually(equal(0))
                }
                
                it("doesnot have listing") {
                    expect(dataDelegate.hasListing).toEventuallyNot(beTrue())
                }
            }
            
            describe("refresh listing") {
                
                beforeEach {
                    sut.retrieveListings()
                    sut.refresh()
                }
                
                it("eventually finishes refreshing") {
                    expect(sut.refreshing).toEventuallyNot(beTrue())
                }
            }
        }
                
        // Helpers
        
        func initDependencies() {
            dataDelegate = SpyListingListViewModelDataDelegate()
            featureFlags = MockFeatureFlags()
            tracker = MockTracker()
        }
        
        func makeSutWithRequester(_ productCount: Int) -> ListingListViewModel {
            
            let requester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 50)
            requester.generateItems(productCount, allowDiscarded: true)
            let multiRequester = ListingListMultiRequester(requesters: [requester])
            let sut = ListingListViewModel(requester: multiRequester, source: .feed)
            sut.dataDelegate = dataDelegate
            return sut
        }
        
        func generateItems(_ numItems: Int, allowDiscarded: Bool) ->  [Product] {
            return MockProduct.makeProductMocks(numItems, allowDiscarded: allowDiscarded) as [Product]
        }
    }
}
