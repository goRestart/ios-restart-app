import LGCoreKit

struct SectionedFeedVMTrackerHelper {
    private let tracker: Tracker
    
    init(tracker: Tracker = TrackerProxy.sharedInstance) {
        self.tracker = tracker
    }
    
    func trackFirstMessage(info: SendMessageTrackingInfo,
                           listingVisitSource: EventParameterListingVisitSource,
                           sectionedFeedChatTrackingInfo: SectionedFeedChatTrackingInfo?,
                           listing: Listing) {
        let event = TrackerEvent.firstMessage(info: info,
                                              listingVisitSource: listingVisitSource,
                                              feedPosition: sectionedFeedChatTrackingInfo?.itemIndexInSection ?? .none,
                                              userBadge: .noBadge,
                                              containsVideo: EventParameterBoolean(bool: listing.containsVideo()),
                                              isProfessional: nil,
                                              sectionName: sectionedFeedChatTrackingInfo?.sectionId)
        tracker.trackEvent(event)
    }
    
    func trackSectionsAndItems(inFeed feed: Feed?,
                               user: User?,
                               categories: [ListingCategory]?,
                               searchQuery: String?,
                               feedSource: EventParameterFeedSource) {
        let successParameter: EventParameterBoolean = feed != nil ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.listingListSectionedFeed(user,
                                                                 categories: categories,
                                                                 searchQuery: searchQuery,
                                                                 sectionItemCount: feed?.totalHorizontalItemCount ?? 0,
                                                                 inifiteSectionItemCount: feed?.totalVerticalItemCount ?? 0,
                                                                 sectionNamesShown: feed?.sectionsShown ?? [],
                                                                 feedSource: feedSource,
                                                                 success: successParameter)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackDuplicates(onPage page: Int, numberOfDuplicates: Int) {
        guard numberOfDuplicates != 0 else { return }
        let trackerEvent = TrackerEvent.filterDuplicatedItemInSectionedFeed(pageNumber: page,
                                                         numberOfDuplicates: numberOfDuplicates)
        tracker.trackEvent(trackerEvent)
    }
    
    func trackLocationTypeChange(from old: LGLocationType?,
                                 to new: LGLocationType?,
                                 locationServiceStatus: LocationServiceStatus,
                                 distanceRadius: Int?) {
        guard old != new else { return }
        let trackerEvent = TrackerEvent.location(locationType: new,
                                                 locationServiceStatus: locationServiceStatus,
                                                 typePage: .automatic,
                                                 zipCodeFilled: nil,
                                                 distanceRadius: distanceRadius)
        tracker.trackEvent(trackerEvent)
    }
}

