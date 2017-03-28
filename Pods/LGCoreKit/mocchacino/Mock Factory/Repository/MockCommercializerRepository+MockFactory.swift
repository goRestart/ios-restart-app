
extension MockCommercializerRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockCommercializerRepository = self.init()
        mockCommercializerRepository.indexResult = CommercializersResult(value: MockCommercializer.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        return mockCommercializerRepository
    }
}

