import LGCoreKit
import IGListKit
import LGComponents


extension Array where Element == FeedSection {
    func toSectionModel(cellMetrics: ListingCellSizeMetrics,
                        myUserRepository: MyUserRepository,
                        listingInterestStates: Set<String>,
                        chatNowTitle: String,
                        preventMessagesFromFeedToProUser: Bool,
                        imageHasFixedSize: Bool,
                        pageNumber: Int) -> [ListDiffable] {
        
        return enumerated().compactMap { (offset, element) -> ListDiffable? in
            guard let sectionType = element.type else { return nil }
            let id = element.id
            let sectionPosition = SectionPosition(page: UInt(bitPattern: pageNumber),
                                                  index: UInt(bitPattern: offset))
            switch sectionType {
            case .adBanner:
                let adsData = AdDataFactory.make(adPosition: Int(sectionPosition.index),
                                                 bannerHeight: LGUIKitConstants.sectionedFeedBannerAdDefaultHeight,
                                                 type: .banner)
                return adsData.listDiffable()
            case .bubbleBar:
                let listingCategories = element.items.toListingCategory()
                return BubbleBarSectionModel(id: id,
                                             sectionPosition: sectionPosition,
                                             items: listingCategories).listDiffable()
            case .verticalListing, .horizontalListing:
                let feedListingDataItems = element.items.toFeedListingData(cellMetrics: cellMetrics,
                                                                           myUserRepository: myUserRepository,
                                                                           listingInterestStates: listingInterestStates,
                                                                           chatNowTitle: chatNowTitle,
                                                                           preventMessagesFromFeedToProUser: preventMessagesFromFeedToProUser,
                                                                           imageHasFixedSize: imageHasFixedSize)
                return ListingSectionModel(id: id,
                                           type: sectionType.toListingSectionType,
                                           title: element.localizedTitle,
                                           links: element.links.toDictionary,
                                           items: feedListingDataItems,
                                           sectionPosition: sectionPosition).listDiffable()
            }
        }
    }
}


extension FeedSectionLinks {
    var toDictionary: [String : String] {
        guard let title = seeAll?.localizedLinkTitle,
            let urlString = seeAll?.url.absoluteString else {
                return [:]
        }
        return [title : urlString]
    }
}

private extension FeedSectionType {
    var toListingSectionType: ListingSectionType {
        switch self {
        case .verticalListing:
            return .vertical
        case .horizontalListing:
            return .horizontal
        case .adBanner:
            return .bannerAds
        case .bubbleBar:
            return .categoryBubble
        }
    }
}
