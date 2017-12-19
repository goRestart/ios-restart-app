extension MockListingStats: MockFactory {
    public static func makeMock() -> MockListingStats {
        return MockListingStats(viewsCount: Int.makeRandom(),
                                favouritesCount: Int.makeRandom())
    }
}
