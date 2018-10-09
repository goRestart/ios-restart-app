import LGCoreKit

extension FeedSection {
    func toSectionModel(cellMetrics: ListingCellSizeMetrics,
                        myUserRepository: MyUserRepository,
                        listingInterestStates: Set<String>,
                        chatNowTitle: String,
                        preventMessagesFromFeedToProUser: Bool,
                        imageHasFixedSize: Bool,
                        sectionPosition: SectionPosition) -> ListingSectionModel {
        let feedListingDataItems = items.toFeedListingData(cellMetrics: cellMetrics,
                                                           myUserRepository: myUserRepository,
                                                           listingInterestStates: listingInterestStates,
                                                           chatNowTitle: chatNowTitle,
                                                           preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                                           imageHasFixedSize: imageHasFixedSize)
        return ListingSectionModel(id: id,
                                   type: type.toListingSectionType,
                                   title: localizedTitle,
                                   links: links.toDictionary,
                                   items: feedListingDataItems,
                                   sectionPosition: sectionPosition)
    }
}

extension Array where Element == FeedSection {
    func toSectionModel(cellMetrics: ListingCellSizeMetrics,
                        myUserRepository: MyUserRepository,
                        listingInterestStates: Set<String>,
                        chatNowTitle: String,
                        preventMessagesFromFeedToProUser: Bool,
                        imageHasFixedSize: Bool,
                        pageNumber: Int) -> [ListingSectionModel] {
        return enumerated().map { $0.element.toSectionModel(cellMetrics: cellMetrics,
                                                            myUserRepository: myUserRepository,
                                                            listingInterestStates: listingInterestStates,
                                                            chatNowTitle: chatNowTitle,
                                                            preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                                            imageHasFixedSize: imageHasFixedSize,
                                                            sectionPosition: SectionPosition(page: UInt(bitPattern: pageNumber),
                                                                                             index: UInt(bitPattern: $0.offset))
            )
        }
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
