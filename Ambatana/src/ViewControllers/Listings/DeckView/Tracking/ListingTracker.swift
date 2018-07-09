import Foundation
import LGCoreKit

final class ListingTracker {
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository

    init(tracker: Tracker, featureFlags: FeatureFlaggeable, myUserRepository: MyUserRepository) {
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
    }

    func isMine(_ listing: Listing) -> EventParameterBoolean {
        return EventParameterBoolean(bool: listing.isMine(myUserRepository: myUserRepository))
    }
}

extension ListingTracker {
    func trackOpenFeaturedInfo(_ listing: Listing) {
        let trackerEvent = TrackerEvent.productDetailOpenFeaturedInfoForListing(listingId: listing.objectId)
        tracker.trackEvent(trackerEvent)
    }

}

// MARK: Money

extension ListingTracker {
    func trackBumpUpBannerShown(_ listing: Listing, type: BumpUpType, storeProductId: String?) {
        let trackerEvent = TrackerEvent.bumpBannerShow(type: EventParameterBumpUpType(bumpType: type),
                                                       listingId: listing.objectId,
                                                       storeProductId: storeProductId,
                                                       isBoost: EventParameterBoolean(bool: type.isBoost))
        tracker.trackEvent(trackerEvent)
    }
}

// MARK: Ads
extension ListingTracker {
    func trackInterstitialAdShown(_ listing: Listing,
                                  adType: EventParameterAdType?,
                                  feedPosition: EventParameterFeedPosition,
                                  adShown: EventParameterBoolean,
                                  typePage: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.adShown(listingId: listing.objectId,
                                                adType: adType,
                                                isMine: isMine(listing),
                                                queryType: nil,
                                                query: nil,
                                                adShown: adShown,
                                                typePage: typePage,
                                                categories: nil,
                                                feedPosition: feedPosition)
        tracker.trackEvent(trackerEvent)
    }

    func trackInterstitialAdTapped(_ listing: Listing,
                                   adType: EventParameterAdType?,
                                   feedPosition: EventParameterFeedPosition,
                                   willLeaveApp: EventParameterBoolean,
                                   typePage: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.adTapped(listingId: listing.objectId,
                                                 adType: adType,
                                                 isMine: isMine(listing),
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: willLeaveApp,
                                                 typePage: typePage,
                                                 categories: nil,
                                                 feedPosition: feedPosition)
        tracker.trackEvent(trackerEvent)
    }
}
