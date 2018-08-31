@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import LGComponents
import Result

final class SectionedFeedRequesterSpec: QuickSpec {

    override func spec() {
        
        var sut: SectionedFeedRequester?
        
        describe("SectionedFeedRequesterSpec") {
            
            let sutError = makeSectionedFeedRequester(withFeedResult: FeedResult(error: .notFound))
            let sutResult = makeSectionedFeedRequester(withFeedResult: FeedResult(value: MockFeed.makeMock()))
            var feedResult: FeedResult?
            let feedCompletion: FeedCompletion = { r in
                feedResult = r
            }
            
            beforeEach {
                feedResult = nil
            }
            
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
        
        func makeSectionedFeedRequester(withFeedResult feedResult: FeedResult) -> SectionedFeedRequester {
            let locationManager = MockLocationManager()
            let mockFeedRepository = MockFeedRepository()
            mockFeedRepository.indexParamsResult = feedResult
            mockFeedRepository.indexUrlResult = feedResult
            let location = LGLocation.makeMock().updating(
                postalAddress: PostalAddress(address: "",
                                             city: "",
                                             zipCode: "",
                                             state: "",
                                             countryCode: "US",
                                             country: "US"))
            locationManager.currentLocation = location
            return SectionedFeedRequester(withFeedRepository: mockFeedRepository,
                                          locationManager: locationManager)
        }
    }
}
