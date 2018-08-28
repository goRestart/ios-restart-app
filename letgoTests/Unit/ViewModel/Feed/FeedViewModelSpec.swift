@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents
import Result

final class FeedViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        
        describe("FeedViewModelSpec") {
            
            let sutError = makeFeedViewModel(withFeedResult: FeedResult(error: .notFound))
            let sutResult = makeFeedViewModel(withFeedResult: FeedResult(value: MockFeed.makeMock()))
            var feedResult: FeedResult?
            let feedCompletion: FeedCompletion = { r in
                feedResult = r
            }
            
            beforeEach {
                feedResult = nil
            }
            
            //  MARK: - Retrieve

            context("Retrieve OK - first") {
                
                beforeEach {
                    sutResult.retrieveFirst(feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns feed") {
                    expect(feedResult?.value).toNot(beNil())
                }
                it("returns no error") {
                    expect(feedResult?.error).to(beNil())
                }
            }
            
            context("Retrieve OK - next withURL") {
                beforeEach {
                    sutResult.retrieveNext(withUrl: URL.makeRandom(), completion: feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns feed") {
                    expect(feedResult?.value).toNot(beNil())
                }
                it("returns no error") {
                    expect(feedResult?.error).to(beNil())
                }
            }
        
            context("Retrieve Error - first") {
                beforeEach {
                    sutError.retrieveFirst(feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns no feed") {
                    expect(feedResult?.value).to(beNil())
                }
                it("returns repository error") {
                    expect(feedResult?.error).toNot(beNil())
                }
            }
            context("Retrieve Error - next withURL") {
                beforeEach {
                    sutError.retrieveNext(withUrl: URL.makeRandom(), completion: feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns no feed") {
                    expect(feedResult?.value).to(beNil())
                }
                it("returns repository error") {
                    expect(feedResult?.error).toNot(beNil())
                }
            }
        }
        
    }
    
}

//  MARK: - Helpers

private extension FeedViewModelSpec {
    
    func makeFeedViewModel(withFeedResult feedResult: FeedResult) -> FeedViewModel {
        let locationManager = MockLocationManager()
        let featureFlags = MockFeatureFlags()
        let mockFeedRepository = MockFeedRepository()
        mockFeedRepository.indexParamsResult = feedResult
        mockFeedRepository.indexUrlResult = feedResult
        let location = LGLocation.makeMock().updating(postalAddress: PostalAddress(address: "",
                                                                                   city: "",
                                                                                   zipCode: "",
                                                                                   state: "",
                                                                                   countryCode: "US",
                                                                                   country: "US"))
        locationManager.currentLocation = location
        return FeedViewModel(feedRepository: mockFeedRepository,
                             searchType: nil,
                             filters: ListingFilters.makeMock(),
                             bubbleTextGenerator: DistanceBubbleTextGenerator(locationManager: locationManager, featureFlags: featureFlags),
                             myUserRepository: MockMyUserRepository.makeMock(),
                             tracker: MockTracker(),
                             pushPermissionsManager: MockPushPermissionsManager(),
                             application: MockApplication(),
                             locationManager: locationManager,
                             featureFlags: featureFlags,
                             keyValueStorage: MockKeyValueStorage(),
                             deviceFamily: .iPhone6Plus)
    }
    
}

