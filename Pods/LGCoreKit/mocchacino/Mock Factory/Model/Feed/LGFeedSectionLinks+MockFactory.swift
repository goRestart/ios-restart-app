extension LGFeedSectionLinks: MockFactory {
    
    public static func makeMock() -> LGFeedSectionLinks {
        return LGFeedSectionLinks(seeAll: LGFeedSectionSeeAllLink.makeMock())
    }
}
