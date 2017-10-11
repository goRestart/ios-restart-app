//
//  RelatedListingsViewModel.swift
//  LetGo
//
//  Created by Facundo Menzella on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

final class RelatedListingsViewModel: SimpleListingsViewModel {

    let originListing: Listing
    let tracker: Tracker

    convenience init(requester: ListingListRequester,
                     originListing listing: Listing,
                     title: String,
                     listingVisitSource: EventParameterListingVisitSource) {
        self.init(requester: requester,
                  originListing: listing,
                  title: title,
                  listingVisitSource: listingVisitSource,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(requester: ListingListRequester,
                     originListing listing: Listing,
                     title: String,
                     listingVisitSource: EventParameterListingVisitSource,
                     tracker: Tracker) {
        self.originListing = listing
        self.tracker = tracker
        super.init(requester: requester,
                  listings: [],
                  title: title,
                  listingVisitSource: listingVisitSource,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            tracker.trackEvent(TrackerEvent.relatedListings(listing: originListing, source: nil))
        }
        super.didBecomeActive(firstTime)
    }

    override func vmProcessReceivedListingPage(_ listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        var processed = Array(listings)
        if page == 0 {
            processed.insert(ListingCellModel(listing: originListing), at: 0)
        }
        return processed
    }
}
