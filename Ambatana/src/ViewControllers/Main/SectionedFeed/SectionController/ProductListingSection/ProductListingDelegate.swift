import LGCoreKit

protocol FeedListingSelectable: class {
    func didSelectListing(_ listing: Listing, thumbnailImage: UIImage?, originFrame: CGRect?)
    func didSelectListing(_ listing: Listing, from feedDataArray: [FeedListingData], thumbnailImage: UIImage?, originFrame: CGRect?, index: Int, sectionIdentifier: String, sectionIndex: UInt?)
}

protocol ProductListingDelegate: class {
    func chatButtonPressedFor(listing: Listing)
    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?,
                             completion: @escaping (InterestedState) -> Void)
    func getUserInfoFor(_ listing: Listing, completion: @escaping (User?) -> Void)
}

protocol EmbeddedInterestedActionDelegate: class {
    /// For listing which is embedded in horizontal sections
    func interestedActionFor(_ listing: Listing,
                             userListing: LocalUser?,
                             touchPoint: CGPoint,
                             completion: @escaping (InterestedState) -> Void)
}

protocol ListingActionDelegate: FeedListingSelectable, ProductListingDelegate { }
