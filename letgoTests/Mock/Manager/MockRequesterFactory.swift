@testable import LetGoGodMode
import Foundation

class MockRequesterFactory: RequesterFactory {
    
    private let featureFlags: FeatureFlaggeable
    private let productCounts: [Int]

    init(featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         productCounts: [Int]) {
        self.featureFlags = featureFlags
        self.productCounts = productCounts
    }

    private var requesterTypes: [RequesterType] {
        switch featureFlags.emptySearchImprovements {
        case .baseline, .control:
            return [.search]
        case .popularNearYou:
            return [.search, .nonFilteredFeed]
        case .similarQueries, .similarQueriesWhenFewResults, .alwaysSimilar:
            return [.search, .similarProducts, .nonFilteredFeed]
        }
    }

    private func buildRequester(withProductCount count: Int) -> ListingListRequester {
        let requester = MockListingListRequester(canRetrieve: true,
                                                 offset: 0,
                                                 pageSize: 50)
        requester.generateItems(count, allowDiscarded: true)
        return ListingListMultiRequester(requesters: [requester])
    }

    func buildRequesterList() -> [ListingListRequester] {
        let zipped = zip(requesterTypes, productCounts)
        return zipped.map { (_, count) in
            buildRequester(withProductCount: count)
        }
    }

    func buildIndexedRequesterList() -> [(RequesterType, ListingListRequester)] {
        let zipped = zip(requesterTypes, productCounts)
        return zipped.map { (type, count) in
            (type, buildRequester(withProductCount: count))
        }
    }
}

