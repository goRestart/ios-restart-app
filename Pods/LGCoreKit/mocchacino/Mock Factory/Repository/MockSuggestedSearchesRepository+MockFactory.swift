
extension MockSuggestedSearchesRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockSuggestedSearchesRepository = self.init()
        mockSuggestedSearchesRepository.indexResult = SuggestedSearchesResult(value: [String].makeRandom())
        return mockSuggestedSearchesRepository
    }
}
