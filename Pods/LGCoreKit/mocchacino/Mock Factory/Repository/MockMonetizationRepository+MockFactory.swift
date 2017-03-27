
extension MockMonetizationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockMonetizationRepository = self.init()
        mockMonetizationRepository.retrieveResult = BumpeableProductResult(value: MockBumpeableProduct.makeMock())
        mockMonetizationRepository.bumpResult = BumpResult(value: Void())
        return mockMonetizationRepository
    }
}

