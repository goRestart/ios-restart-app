
extension MockSearchRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockSearchRepository = self.init()
        mockSearchRepository.indexResult = TrendingSearchesResult(value: [String].makeRandom())
        return mockSearchRepository
    }
}
