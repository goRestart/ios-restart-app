public struct MockFeedSection: FeedSection {
    public var id: String
    public var type: FeedSectionType?
    public var localizedTitle: String?
    public var links: FeedSectionLinks
    public var items: [FeedListing]
}

extension FeedSectionType {
    public static func makeRandom() -> FeedSectionType {
        let allCases: [FeedSectionType] = [.horizontalListing, .verticalListing]
        return allCases.random() ?? .horizontalListing
    }
}

extension MockFeedSection: MockFactory {
    public static func makeMock() -> MockFeedSection {
        return MockFeedSection(id: String.makeRandom(),
                               type: FeedSectionType.makeRandom(),
                               localizedTitle: String.makeRandom(),
                               links: MockFeedSectionLinks.makeMock(),
                               items: FeedListing.makeMocks(count: Int.makeRandom(min: 0, max: 5)))
    }
}
