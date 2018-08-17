extension LGFeedSectionSeeAllLink: MockFactory {
    
    public static func makeMock() -> LGFeedSectionSeeAllLink {
        return LGFeedSectionSeeAllLink(
            localizedLinkTitle: String.makeRandom(),
            url: URL.makeRandom(),
            type: .feed)
    }
}

