import LGCoreKit

extension Feed {
    func horizontalSections(_ featureFlags: FeatureFlaggeable,
                            _ myUserRepository: MyUserRepository,
                            _ keyValueStorage: KeyValueStorageable,
                            _ numberOfColumns: Int,
                            _ pageNumber: Int) -> [ListingSectionModel] {
        let listingInterestStates = keyValueStorage.interestingListingIDs
        let cellMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        return sections.toSectionModel(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: featureFlags.chatNowButtonText,
                                       preventMessagesFromFeedToProUser: featureFlags.preventMessagesFromFeedToProUsers.isActive,
                                       imageHasFixedSize: true,
                                       pageNumber: pageNumber).filter { $0.type == .horizontal }
    }
    
    func verticalItems(_ featureFlags: FeatureFlaggeable,
                       _ myUserRepository: MyUserRepository,
                       _ keyValueStorage: KeyValueStorageable,
                       _ numberOfColumns: Int) -> [FeedListingData]  {
        let listingInterestStates = keyValueStorage.interestingListingIDs
        let cellMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        return items.toFeedListingData(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: featureFlags.chatNowButtonText,
                                       preventMessagesFromFeedToProUser: featureFlags.preventMessagesFromFeedToProUsers.isActive,
                                       imageHasFixedSize: false)
    }
}
