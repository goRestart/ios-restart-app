import LGCoreKit

extension FeedListing {
    var listing: Listing {
        switch self {
        case .product(let listing):
            return listing
        }
    }
}
