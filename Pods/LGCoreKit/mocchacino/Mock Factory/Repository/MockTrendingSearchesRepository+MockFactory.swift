
extension MockTrendingSearchesRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockTrendingSearchesRepository = self.init()
        mockTrendingSearchesRepository.indexResult = TrendingSearchesResult(value: [String].makeRandom())
        return mockTrendingSearchesRepository
    }
}
