@testable import LetGoGodMode
import LGCoreKit

// MARK:- Spy Delegate

final class SpyListingListViewModelDataDelegate: ListingListViewModelDataDelegate {
    func listingListVMDidSucceedRetrievingCache(viewModel: ListingListViewModel) { }

    
    var count = 0
    var hasListing: Bool?
    
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, withResultsCount resultsCount: Int, hasListings: Bool, containsRecentListings: Bool) {
        count = resultsCount
        hasListing = hasListings
    }
    
    func vmProcessReceivedListingPage(_ Listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        return Listings
    }
    
    func vmDidSelectSellBanner(_ type: String) { }
    
    func vmDidSelectCollection(_ type: CollectionCellType) { }
    
    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt, hasListings: Bool, error: RepositoryError) { }
    
    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?, originFrame: CGRect?) { }
}
