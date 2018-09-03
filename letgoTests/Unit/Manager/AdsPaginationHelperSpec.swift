@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

final class AdsPaginationHelperSpec: QuickSpec {
    
    override func spec() {
        
        let featureFlags = MockFeatureFlags()
        
        var sut: AdsPaginationHelper!
        var result: [Int] = []
        
        beforeEach {
            featureFlags.showAdsInFeedWithRatio = .ten
            sut = AdsPaginationHelper(featureFlags: featureFlags)
        }
        describe("adIndexesPositions") {
            
            context("page size 20") {
                context("first page only") {
                    beforeEach {
                        result = sut.adIndexesPositions(withItemListCount: 20)
                    }
                    it("added at third place and offset +10") {
                        expect(result) == [3, 12]
                    }
                }
                context("second page") {
                    beforeEach {
                        result = sut.adIndexesPositions(withItemListCount: 20)
                        result = sut.adIndexesPositions(withItemListCount: 20)
                    }
                    it("added at right places") {
                        expect(result) == [1, 10, 19]
                    }
                }
            }
            
            context("page size 50") {
                context("first page only") {
                    beforeEach {
                        result = sut.adIndexesPositions(withItemListCount: 50)
                    }
                    it("added at third place and offset +10") {
                        expect(result) == [3, 12, 21, 30, 39, 48]
                    }
                }
            }
            afterEach {
                result = []
                sut.reset()
            }
        }
    }
}
