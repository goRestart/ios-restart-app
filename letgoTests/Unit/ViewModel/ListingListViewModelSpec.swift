@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class ListingListViewModelSpec: QuickSpec {

    var sut: ListingListViewModel!
    
    override func spec() {

        var requesterFactory: MockRequesterFactory!
        var dataDelegate: SpyListingListViewModelDataDelegate!
        var featureFlags: MockFeatureFlags!
        var tracker: Tracker!
        
        // Init VM with requester factory

        describe("init view model with requester factory containing 1 requester") {

            beforeEach {
                initDependencies()
                self.sut = makeSutWithFactory(.control, productCounts: [10])
            }

            context("initial requester from factory") {

                it("equal to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equal to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }

            context("retrieve listing") {

                beforeEach {
                    self.sut.retrieveListings()
                }

                it("receives 10 products") {
                    expect(dataDelegate.count).toEventually(equal(10))
                }

                it("requester type used to get products is .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
            }
        }

        describe("init view model with requester factory containing 2 requesters with [15, 30] products") {

            beforeEach {
                initDependencies()
                self.sut = makeSutWithFactory(.popularNearYou, productCounts: [15, 30])
            }

            context("initial requester from factory") {

                it("equal to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equal to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }

            context("retrieve listing") {

                beforeEach {
                    self.sut.retrieveListings()
                }

                it("receives 15 products") {
                    expect(dataDelegate.count).toEventually(equal(15))
                }

                it("requester type used to get products is .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
            }
        }

        describe("init view model with requester factory containing 2 requesters with [0, 40] products") {

            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    self.sut = makeSutWithFactory(.popularNearYou, productCounts: [0, 40])
                    self.sut.retrieveListings()
                }

                it("receives 40 products") {
                    expect(dataDelegate.count).toEventually(equal(40))
                }
                
                it("requester type used to get products is .nonFilteredFeed") {
                    expect(dataDelegate.requesterType).toEventually(equal(.nonFilteredFeed))
                }
            }
        }

        describe("init view model with requester factory containing 3 requesters with [10, 25, 40] products") {

            context("initial requester from factory") {
                
                it("equal to listingListRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.listingListRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
                
                it("equal to currentActiveRequester") {
                    let factoryRequester = requesterFactory.buildRequesterList()[0]
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).to(be(true))
                }
            }
            
            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    self.sut = makeSutWithFactory(.similarQueries, productCounts: [10, 25, 40])
                    self.sut.retrieveListings()
                }
                
                it("receives 10 products") {
                    expect(dataDelegate.count).toEventually(equal(10))
                }
                
                it("requester type used to get products is .search") {
                    expect(dataDelegate.requesterType).toEventually(equal(.search))
                }
            }
        }

        describe("init view model with requester factory containing 3 requesters with [0, 25, 40] products") {

            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    self.sut = makeSutWithFactory(.similarQueries, productCounts: [0, 25, 40])
                    self.sut.retrieveListings()
                }
                
                it("receives 25 products") {
                    expect(dataDelegate.count).toEventually(equal(25))
                }
                
                it("requester type used to get products is .similarProducts") {
                    expect(dataDelegate.requesterType).toEventually(equal(.similarProducts))
                }

                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[1]
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }

        describe("init view model with requester factory containing 3 requesters both with [0, 25, 40] products") {

            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    self.sut = makeSutWithFactory(.similarQueries, productCounts: [0, 0, 40])
                    self.sut.retrieveListings()
                }
                
                it("receives 40 products") {
                    expect(dataDelegate.count).toEventually(equal(40))
                }
                
                it("requester type used to get products is .nonFilteredFeed") {
                    expect(dataDelegate.requesterType).toEventually(equal(.nonFilteredFeed))
                }
                
                it("final active requester is identical to the 2nd requester from factory") {
                    let factoryRequester = requesterFactory.buildRequesterList()[2]
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: factoryRequester)).toEventually(beTrue())
                }
            }
        }


        // Init VM with requester

        describe("init view model with requester containing 33 products") {

            context("retrieve listing") {
                beforeEach {
                    initDependencies()
                    self.sut = makeSutWithRequester(33)
                    self.sut.retrieveListings()
                }

                it("receives 33 products") {
                    expect(dataDelegate.count).toEventually(equal(33))
                }
                
                it("requester type used to get products is .nonFilteredFeed") {
                    expect(self.sut.currentActiveRequester?.isEqual(toRequester: self.sut.listingListRequester!)).to(beTrue())
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
                                           requesterFactory: requesterFactory)
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
    }
}


// MARK:- Spy Delegate

final class SpyListingListViewModelDataDelegate: ListingListViewModelDataDelegate {

    var count = 0
    var requesterType: RequesterType?

    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, withResultsCount resultsCount: Int, hasListings: Bool) {
        count = resultsCount
        requesterType = viewModel.currentRequesterType
    }

    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        return Listings
    }

    func vmDidSelectSellBanner(_ type: String) { }

    func vmDidSelectCollection(_ type: CollectionCellType) { }

    func vmDidSelectMostSearchedItems() { }

    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool, error: RepositoryError) { }

    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?, originFrame: CGRect?) { }
}
