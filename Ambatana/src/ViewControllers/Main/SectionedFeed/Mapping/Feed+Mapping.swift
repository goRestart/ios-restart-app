import LGCoreKit
import IGListKit

extension Feed {
    func horizontalSections(featureFlags: FeatureFlaggeable,
                            myUserRepository: MyUserRepository,
                            keyValueStorage: KeyValueStorageable,
                            numberOfColumns: Int,
                            pageNumber: Int) -> [ListDiffable] {
        let listingInterestStates = keyValueStorage.interestingListingIDs
        let cellMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        return sections.toSectionModel(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: featureFlags.chatNowButtonText,
                                       preventMessagesFromFeedToProUser: featureFlags.preventMessagesFromFeedToProUsers.isActive,
                                       imageHasFixedSize: true,
                                       pageNumber: pageNumber)
    }
    
    func verticalItems(featureFlags: FeatureFlaggeable,
                       myUserRepository: MyUserRepository,
                       keyValueStorage: KeyValueStorageable,
                       numberOfColumns: Int) -> [FeedListingData]  {
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
