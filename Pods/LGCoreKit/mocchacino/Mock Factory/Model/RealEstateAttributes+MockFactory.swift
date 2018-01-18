extension RealEstateAttributes: MockFactory {
    public static func makeMock() -> RealEstateAttributes {
        let hasProperty: Bool = Bool.makeRandom()
        let hasOfferType: Bool = Bool.makeRandom()
        let hasBedrooms: Bool = Bool.makeRandom()
        let hasBathrooms: Bool = Bool.makeRandom()
        let hasLivingRooms: Bool = Bool.makeRandom()
        let hasSizeSquareMeters: Bool = Bool.makeRandom()
        return RealEstateAttributes(propertyType: hasProperty ? RealEstatePropertyType.makeMock() : nil,
                                    offerType: hasOfferType ? RealEstateOfferType.makeMock() : nil,
                                    bedrooms: hasBedrooms ? Int.makeRandom() : nil,
                                    bathrooms: hasBathrooms ? Float.makeRandom() : nil,
                                    livingRooms: hasLivingRooms ? Int.makeRandom() : nil,
                                    sizeSquareMeters: hasSizeSquareMeters ? Int.makeRandom() : nil)
    }
}
