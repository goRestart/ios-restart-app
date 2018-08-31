extension LGFeedItemOwner: MockFactory {
    public static func makeMock() -> LGFeedItemOwner {
        return LGFeedItemOwner(
            id: String.makeRandom(),
            name: String.makeRandom(),
            avatarUrl: nil,
            countryCode: nil,
            city: nil,
            zipCode: nil)
    }
}
