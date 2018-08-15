extension LGFeedSection: MockFactory {
    
    public static func makeMock() -> LGFeedSection {
        return LGFeedSection(id: String.makeRandom(),
                             type: .horizontalListing,
                             localizedTitle: String.makeRandom(),
                             links: LGFeedSectionLinks.makeMock(),
                             items: FeedListing.makeMocks(count: 5))
    }
}
