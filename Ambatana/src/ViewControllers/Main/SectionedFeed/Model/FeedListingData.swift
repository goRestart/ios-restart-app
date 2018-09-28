import LGComponents
import LGCoreKit

struct FeedListingData: Diffable {
    let listing: Listing // Needed in navigators
    let isFree: Bool
    let isFeatured: Bool
    let isMine: Bool
    let price: String
    let imageSize: CGSize
    let imageHasFixedSize: Bool
    let interestedState: InterestedState
    let isDiscarded: Bool
    let preventMessageToProUsers: Bool
    let chatNowTitle: String
}

extension FeedListingData {
    
    static func ==(lhs: FeedListingData, rhs: FeedListingData) -> Bool {
        return lhs.listing.objectId == rhs.listing.objectId
                && lhs.listing.category == rhs.listing.category
                && lhs.isFree == rhs.isFree
                && lhs.isFeatured == rhs.isFeatured
                && lhs.isMine == rhs.isMine
                && lhs.price == rhs.price
                && lhs.imageSize == rhs.imageSize
                && lhs.imageHasFixedSize == rhs.imageHasFixedSize
                && lhs.interestedState == rhs.interestedState
                && lhs.isDiscarded == rhs.isDiscarded
                && lhs.preventMessageToProUsers == rhs.preventMessageToProUsers
                && lhs.chatNowTitle == rhs.chatNowTitle
    }
    
    var diffIdentifier: String {
        // FIXME: What do I put if listingId is nil (although it shouldn't be nil according to backend)
        // And what is the best differentiator?
        return listingId ?? listing.location.coordsToQuadKey(2)
    }
}

extension FeedListingData {
    
    var listingId: String? {
        return listing.objectId
    }
    
    var thumbUrl: URL? {
        return listing.thumbnail?.fileURL
    }
    
    var mediaThumbUrl: URL? {
        return listing.mediaThumbnail?.file.fileURL
    }
    
    var mediaThumbType: MediaType? {
        return listing.mediaThumbnail?.type
    }
    
    var title: String? {
        return listing.title
    }
    
    var user: UserListing {
        return listing.user
    }
    
    var priceType: String? {
        return listing.service?.servicesAttributes.paymentFrequency?.localizedDisplayName
    }
}

extension FeedListingData {
    struct Lenses {
        static let interestedState = Lens<FeedListingData, InterestedState>(
            get: {$0.interestedState},
            set: {(value, me) in FeedListingData(listing: me.listing,
                                                 isFree: me.isFree,
                                                 isFeatured: me.isFeatured,
                                                 isMine: me.isMine,
                                                 price: me.price,
                                                 imageSize: me.imageSize,
                                                 imageHasFixedSize: me.imageHasFixedSize,
                                                 interestedState: value,
                                                 isDiscarded: me.isDiscarded,
                                                 preventMessageToProUsers: me.preventMessageToProUsers,
                                                 chatNowTitle: me.chatNowTitle) }
        )
    }
}
