public struct MockFeedSectionLinks: FeedSectionLinks {
    public var seeAll: FeedSectionSeeAllLink?
}

extension MockFeedSectionLinks: MockFactory {
    public static func makeMock() -> MockFeedSectionLinks {
        return MockFeedSectionLinks(seeAll: MockFeedSectionSeeAllLink.makeMock())
    }
}
