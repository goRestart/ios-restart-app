@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

final class ListingListViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ListingListViewModel!
        
        var requesterFactory: MockRequesterFactory!
        var dataDelegate: SpyListingListViewModelDataDelegate!
        var featureFlags: MockFeatureFlags!
        var tracker: Tracker!
        
        // Init VM with requester factory
        describe("init view model with requester factory containing 1 requester") {
            
            beforeEach {
                initDependencies()
                sut = makeSutWithFactory(.control, productCounts: [10])
            }
            
            context("initial requester from factory") {
                
                it("equal to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equals to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }
            context("retrieve listing") {
                beforeEach {
                    sut.retrieveListings()
                }
                
                it("receives 10 products") {
                    expect(dataDelegate.count).toEventually(equal(10))
                }
                it("requester type used to get products is .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
                
                it("does have listing") {
                    expect(dataDelegate.hasListing).toEventually(beTrue())
                }
            }
            
            describe("refresh listing") {
                
                beforeEach {
                    sut.refresh()
                }

                it("eventually finishes refreshing") {
                    expect(sut.refreshing).toEventuallyNot(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 2 requesters with [15, 30] products") {
            
            beforeEach {
                initDependencies()
                sut = makeSutWithFactory(.popularNearYou, productCounts: [15, 30])
            }
            
            context("initial requester from factory") {
                it("equal to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equal to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }
            context("retrieve listing") {
                beforeEach {
                    sut.retrieveListings()
                }
                
                it("receives 15 products") {
                    expect(dataDelegate.count).toEventually(equal(15))
                }
                it("requester type used to get products is .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
                
                it("does have listing") {
                    expect(dataDelegate.hasListing).toEventually(beTrue())
                }
            }
            
            describe("refresh listing") {
                
                beforeEach {
                    sut.refresh()
                }
                
                it("indicates that is refreshing") {
                    expect(sut.refreshing) == true
                }
                
                it("eventually finishes refreshing") {
                    expect(sut.refreshing).toEventuallyNot(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 2 requesters with [0, 40] products") {
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.popularNearYou, productCounts: [0, 40])
                    sut.retrieveListings()
                }
                
                it("receives 40 products") {
                    expect(dataDelegate.count).toEventually(equal(40))
                }
                
                it("uses a requester of type of .nonFilteredFeed since the 1st request has no product") {
                    expect(dataDelegate.requesterType).toEventually(equal(.nonFilteredFeed))
                }
                
                it("does have listing") {
                    expect(dataDelegate.hasListing).toEventually(beTrue())
                }
            }
            
            describe("refresh listing") {
                
                beforeEach {
                    sut = makeSutWithFactory(.popularNearYou, productCounts: [0, 40])
                    sut.retrieveListings()
                    sut.refresh()
                }
                
                it("eventually finishes refreshing") {
                    expect(sut.refreshing).toEventuallyNot(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 3 requesters with [10, 25, 40] products") {
            context("initial requester from factory") {
                it("equals to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equals to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }
            
            describe("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.similarQueries, productCounts: [10, 25, 40])
                    sut.retrieveListings()
                }
                
                it("receives 10 products") {
                    expect(dataDelegate.count).toEventually(equal(10))
                }
                
                it("returns the last used requester type as .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
                
                it("does have listing") {
                    expect(dataDelegate.hasListing).toEventually(beTrue())
                }
            }
            
            describe("refresh listing") {
                beforeEach {
                    sut = makeSutWithFactory(.similarQueries, productCounts: [10, 25, 40])
                    sut.retrieveListings()
                    sut.refresh()
                }
                
                it("eventually finishes refreshing") {
                    expect(sut.refreshing).toEventuallyNot(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 3 requesters with [0, 25, 40] products") {
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.similarQueries, productCounts: [0, 25, 40])
                    sut.retrieveListings()
                }
                
                it("receives 25 products") {
                    expect(dataDelegate.count).toEventually(equal(25))
                }
                
                it("returns the last used requester type as .similarProducts") {
                    expect(dataDelegate.requesterType).toEventually(equal(.similarProducts))
                }
                
                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[1]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 3 requesters both with [0, 0, 40] products") {
            
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.similarQueries, productCounts: [0, 0, 40])
                    sut.retrieveListings()
                }
                
                it("receives 40 products") {
                    expect(dataDelegate.count).toEventually(equal(40))
                }
                
                it("returns the last used requester type as .nonFilteredFeed") {
                    expect(dataDelegate.requesterType).toEventually(equal(.nonFilteredFeed))
                }
                
                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[2]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 3 requesters both with  [6, 21, 40] products") {
            
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.similarQueriesWhenFewResults, productCounts: [6, 21, 40])
                    sut.retrieveListings()
                }
                
                it("the last object count received is 21") {
                    expect(dataDelegate.count).toEventually(equal(21))
                }
                
                it("requester type used to get products is .similarProducts") {
                    expect(dataDelegate.requesterType).toEventually(equal(.similarProducts))
                }
                
                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[1]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }
        
        describe("init view model with requester factory containing 3 requesters both with  [4, 14, 40] products for .alwaysSimilar case") {
            
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    sut = makeSutWithFactory(.alwaysSimilar, productCounts: [4, 14, 40])
                    sut.retrieveListings()
                }
                
                it("the last object count received is 14") {
                    expect(dataDelegate.count).toEventually(equal(14))
                    expect(sut.numberOfListings).toEventually(equal(14))
                }
                
                it("requester type used to get products is .similarProducts") {
                    expect(dataDelegate.requesterType).toEventually(equal(.similarProducts))
                }
                
                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[1]
                    expect(sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }
        
        
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
                    expect(sut.currentActiveRequester?.isEqual(toRequester: sut.listingListRequester!)).to(beTrue())
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
        
        func makeSutWithFactory(_ flag: EmptySearchImprovements,
                                productCounts: [Int])  -> ListingListViewModel {
            featureFlags.emptySearchImprovements = flag
            requesterFactory = MockRequesterFactory(featureFlags: featureFlags,
                                                    productCounts: productCounts)
            let sut = ListingListViewModel(numberOfColumns: 3,
                                           tracker: tracker,
                                           featureFlags: featureFlags,
                                           requesterFactory: requesterFactory,
                                           searchType: SearchType.user(query: "abc"))
            sut.dataDelegate = dataDelegate
            return sut
        }
        
        func makeSutWithRequester(_ productCount: Int) -> ListingListViewModel {
            
            let requester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 50)
            requester.generateItems(productCount, allowDiscarded: true)
            let multiRequester = ListingListMultiRequester(requesters: [requester])
            let sut = ListingListViewModel(requester: multiRequester)
            sut.dataDelegate = dataDelegate
            return sut
        }
        
        func generateItems(_ numItems: Int, allowDiscarded: Bool) ->  [Product] {
            return MockProduct.makeProductMocks(numItems, allowDiscarded: allowDiscarded) as [Product]
        }
    }
}
