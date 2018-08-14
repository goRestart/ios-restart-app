extension LGFeed: MockFactory {
    
    public static func makeMock() -> LGFeed {
        return LGFeed(pagination: LGPaginationLinks.makeMock(),
                      sections: LGFeedSection.makeMocks(count: 2),
                      items: FeedListing.makeMocks(count: 10))
    }
}
