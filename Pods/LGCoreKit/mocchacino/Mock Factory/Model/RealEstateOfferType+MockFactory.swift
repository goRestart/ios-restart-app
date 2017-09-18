extension RealEstateOfferType: MockFactory {
    public static func makeMock() -> RealEstateOfferType {
        let allValues: [RealEstateOfferType] = [.sale, .rent]
        return allValues.random()!
    }
}
