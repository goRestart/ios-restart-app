public struct MockFeed: Feed {
    public var pagination: PaginationLinks
    public var sections: [FeedSection]
    public var items: [FeedListing]
}

extension MockFeed: MockFactory {
    public static func makeMock() -> MockFeed {
        return MockFeed(pagination: MockPaginationLinks.makeMock(),
                        sections: MockFeedSection.makeMocks(count: Int.makeRandom(min: 0, max: 5)),
                        items: FeedListing.makeMocks(count: Int.makeRandom(min: 0, max: 5)))
    }
}
