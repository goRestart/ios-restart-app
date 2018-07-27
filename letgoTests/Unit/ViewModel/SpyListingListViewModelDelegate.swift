@testable import LetGoGodMode
import LGCoreKit

// MARK:- Spy Delegate

final class SpyListingListViewModelDataDelegate: ListingListViewModelDataDelegate {
    
    var count = 0
    var requesterType: RequesterType?
    var hasListing: Bool?
    
    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt, withResultsCount resultsCount: Int, hasListings: Bool) {
        count = resultsCount
        requesterType = viewModel.currentRequesterType
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
