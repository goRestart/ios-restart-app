
extension MockMonetizationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockMonetizationRepository = self.init()
        mockMonetizationRepository.retrieveResult = BumpeableListingResult(value: MockBumpeableListing.makeMock())
        mockMonetizationRepository.bumpResult = BumpResult(value: Void())
        return mockMonetizationRepository
    }
}

