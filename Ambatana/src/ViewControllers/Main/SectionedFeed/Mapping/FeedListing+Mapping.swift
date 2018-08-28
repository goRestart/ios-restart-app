import LGCoreKit
import LGComponents


extension FeedListing {
    
    private var listing: Listing {
        switch self {
        case .product(let listing):
            return listing
        }
    }
    
    func toFeedListingData(cellMetrics: ListingCellSizeMetrics,
                           myUserRepository: MyUserRepository,
                           listingInterestStates: Set<String>,
                           chatNowTitle: String,
                           freePostingAllowed: Bool,
                           preventMessagesFromFeedToProUser: Bool,
                           imageHasFixedSize: Bool) -> FeedListingData {
        let isMine = listing.isMine(myUserRepository: myUserRepository)
        let originalCellSize = listing.thumbnailSize?.toCGSize ?? .zero
        let imageSize = cellMetrics.cellAdaptedSize(fromOriginalCellSize: originalCellSize)
        let interestedState = listing.interestedState(myUserRepository: myUserRepository,
                                                      listingInterestStates: listingInterestStates)
        let preventMessageToProUsers =  !preventMessagesFromFeedToProUser && !listing.isVertical
        return FeedListingData(listing: listing,
                               isFree: listing.price.isFree,
                               isFeatured: listing.featured ?? false,
                               isMine: isMine,
                               price: listing.priceString(freeModeAllowed: freePostingAllowed),
                               imageSize: imageSize,
                               imageHasFixedSize: imageHasFixedSize,
                               interestedState: interestedState,
                               isDiscarded: listing.status.isDiscarded,
                               preventMessageToProUsers: preventMessageToProUsers,
                               chatNowTitle: chatNowTitle)
    }
}


extension Array where Element == FeedListing {
    func toFeedListingData(cellMetrics: ListingCellSizeMetrics,
                           myUserRepository: MyUserRepository,
                           listingInterestStates: Set<String>,
                           chatNowTitle: String,
                           freePostingAllowed: Bool,
                           preventMessagesFromFeedToProUser: Bool,
                           imageHasFixedSize: Bool) -> [FeedListingData] {
        return map { $0.toFeedListingData(cellMetrics: cellMetrics,
                                          myUserRepository: myUserRepository,
                                          listingInterestStates: listingInterestStates,
                                          chatNowTitle: chatNowTitle,
                                          freePostingAllowed: freePostingAllowed,
                                          preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                          imageHasFixedSize: imageHasFixedSize) }
    }
}

