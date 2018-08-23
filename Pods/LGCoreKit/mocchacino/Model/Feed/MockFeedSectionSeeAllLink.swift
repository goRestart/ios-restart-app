public struct MockFeedSectionSeeAllLink: FeedSectionSeeAllLink {
    public var localizedLinkTitle: String
    public var url: URL
    public var type: FeedLinkType?
}

extension FeedLinkType {
    public static func makeRandom() -> FeedLinkType {
        let allCases: [FeedLinkType] = [.feed]
        return allCases.random() ?? .feed
    }
}

extension MockFeedSectionSeeAllLink: MockFactory {
    public static func makeMock() -> MockFeedSectionSeeAllLink {
        return MockFeedSectionSeeAllLink(localizedLinkTitle: String.makeRandom(),
                                         url: URL.makeRandom(),
                                         type: FeedLinkType.makeRandom())
    }
}
