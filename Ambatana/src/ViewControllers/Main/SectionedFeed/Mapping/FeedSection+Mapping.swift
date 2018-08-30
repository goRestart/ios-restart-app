import LGCoreKit

extension FeedSection {
    func toSectionModel(cellMetrics: ListingCellSizeMetrics,
                        myUserRepository: MyUserRepository,
                        listingInterestStates: Set<String>,
                        chatNowTitle: String,
                        freePostingAllowed: Bool,
                        preventMessagesFromFeedToProUser: Bool,
                        imageHasFixedSize: Bool) -> ListingSectionModel {
        let feedListingDataItems = items.toFeedListingData(cellMetrics: cellMetrics,
                                                           myUserRepository: myUserRepository,
                                                           listingInterestStates: listingInterestStates,
                                                           chatNowTitle: chatNowTitle,
                                                           freePostingAllowed: freePostingAllowed,
                                                           preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                                           imageHasFixedSize: imageHasFixedSize)
        return ListingSectionModel(id: id,
                                   type: type.toListingSectionType,
                                   title: localizedTitle,
                                   links: links.toDictionary,
                                   items: feedListingDataItems)
    }
}

extension Array where Element == FeedSection {
    func toSectionModel(cellMetrics: ListingCellSizeMetrics,
                        myUserRepository: MyUserRepository,
                        listingInterestStates: Set<String>,
                        chatNowTitle: String,
                        freePostingAllowed: Bool,
                        preventMessagesFromFeedToProUser: Bool,
                        imageHasFixedSize: Bool) -> [ListingSectionModel] {
        return map { $0.toSectionModel(cellMetrics: cellMetrics,
                                       myUserRepository: myUserRepository,
                                       listingInterestStates: listingInterestStates,
                                       chatNowTitle: chatNowTitle,
                                       freePostingAllowed: freePostingAllowed,
                                       preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                       imageHasFixedSize: imageHasFixedSize) }
    }
}


extension FeedSectionLinks {
    var toDictionary: [String : String] {
        return [seeAll.localizedLinkTitle : seeAll.url.absoluteString]
    }
}

private extension FeedSectionType {
    var toListingSectionType: ListingSectionType {
        switch self {
        case .verticalListing:
            return .vertical
        case .horizontalListing:
            return .horizontal
        }
    }
}
