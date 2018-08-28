import LGCoreKit

extension Feed {
    func horizontalSections(_ featureFlags: FeatureFlaggeable,
                            _ myUserRepository: MyUserRepository,
                            _ keyValueStorage: KeyValueStorageable,
                            _ numberOfColumns: Int) -> [ListingSectionModel] {
        let listingInterestStates = keyValueStorage.interestingListingIDs
        let cellMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        return sections.toSectionModel(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: featureFlags.chatNowButtonText,
                                       freePostingAllowed: featureFlags.freePostingModeAllowed,
                                       preventMessagesFromFeedToProUser: featureFlags.preventMessagesFromFeedToProUsers.isActive,
                                       imageHasFixedSize: true).filter { $0.type == .horizontal }
    }
    
    func verticalItems(_ featureFlags: FeatureFlaggeable,
                       _ myUserRepository: MyUserRepository,
                       _ keyValueStorage: KeyValueStorageable,
                       _ numberOfColumns: Int) -> [FeedListingData] {
        let listingInterestStates = keyValueStorage.interestingListingIDs
        let cellMetrics = ListingCellSizeMetrics(numberOfColumns: numberOfColumns)
        return items.toFeedListingData(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: featureFlags.chatNowButtonText,
                                       freePostingAllowed: featureFlags.freePostingModeAllowed,
                                       preventMessagesFromFeedToProUser: featureFlags.preventMessagesFromFeedToProUsers.isActive,
                                       imageHasFixedSize: false)
    }
    
    var totalHorizontalItemCount: Int {
        return sections.map{ $0.items.count }.reduce(0, +)
    }
    
    var totalVerticalItemCount: Int {
        return items.count
    }
    
    var sectionsShown: [String] {
        return sections.map{ $0.id }
    }
}
