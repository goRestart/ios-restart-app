
extension MockMonetizationRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockMonetizationRepository = self.init()
        mockMonetizationRepository.retrieveResult = BumpeableListingResult(value: MockBumpeableListing.makeMock())
        mockMonetizationRepository.bumpResult = BumpResult(value: Void())
        mockMonetizationRepository.availablePurchasesResult = ListingAvailablePurchasesResult(value: MockListingAvailablePurchases.makeMocks())
        return mockMonetizationRepository
    }
}

