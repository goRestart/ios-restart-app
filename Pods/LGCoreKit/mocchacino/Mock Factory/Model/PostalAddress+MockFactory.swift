extension PostalAddress: MockFactory {
    public static func makeMock() -> PostalAddress {
        return PostalAddress(address: String?.makeRandom(),
                             city: String?.makeRandom(),
                             zipCode: String?.makeRandom(),
                             state: String?.makeRandom(),
                             countryCode: String?.makeRandom(),
                             country: String?.makeRandom())
    }
}
