extension MockProductStats: MockFactory {
    public static func makeMock() -> MockProductStats {
        return MockProductStats(viewsCount: Int.makeRandom(),
                                favouritesCount: Int.makeRandom())
    }
}
