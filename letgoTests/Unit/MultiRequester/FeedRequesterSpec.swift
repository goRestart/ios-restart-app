@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

final class FeedRequesterSpec: QuickSpec {
    
    override func spec() {
        var sut: FeedRequester!
        
        var feedResult: FeedResult!
        let feedCompletion: FeedCompletion =  { r in
            feedResult = r
        }

        describe("FeedRequesterSpec") {
            let feed = MockFeed.makeMock()
            sut = makeFeedRequester(withFeedResult: FeedResult(value: feed))
            
            context("retrieve with index params") {
                
                beforeEach {
                    sut.retrieve(feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns same items feed listings") {
                    expect(feedResult.value?.items.count).to(equal(feed.items.count))
                }
                it("returns same sections") {
                    expect(feedResult.value?.sections.count).to(equal(feed.sections.count))
                }
                it("returns same item page") {
                    expect(feedResult.value?.pagination.this).to(equal(feed.pagination.this))
                }
            }
            
            context("retrieve with URL") {
                
                beforeEach {
                    sut.retrieve(nextURL: URL.makeRandom(), feedCompletion)
                    expect(feedResult).toEventuallyNot(beNil())
                }
                it("returns same items feed listings") {
                    expect(feedResult.value?.items.count).to(equal(feed.items.count))
                }
                it("returns same sections") {
                    expect(feedResult.value?.sections.count).to(equal(feed.sections.count))
                }
                it("returns same item page") {
                    expect(feedResult.value?.pagination.this).to(equal(feed.pagination.this))
                }
            }
            beforeEach {
                feedResult = nil
            }
        }
    }
    
}

//  MARK: - Helpers

extension FeedRequesterSpec {
 
    private func makeFeedRequester(withFeedResult feedResult: FeedResult) -> FeedRequester {
        let mockIndexParams = FeedIndexParameters(countryCode: "US",
                                                  location: LGLocationCoordinates2D(latitude: 0, longitude: 0),
                                                  locale: "",
                                                  page: 0,
                                                  pageSize: Int.makeRandom(min: 0, max: 50),
                                                  variant: "variantA")
        let mockFeedRepository = MockFeedRepository()
        mockFeedRepository.indexParamsResult = feedResult
        mockFeedRepository.indexUrlResult = feedResult
        
        return FeedRequester(withRepository: mockFeedRepository, params: mockIndexParams)
    }
    
}
