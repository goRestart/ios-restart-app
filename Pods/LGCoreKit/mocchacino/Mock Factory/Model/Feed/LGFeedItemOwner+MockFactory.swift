extension LGFeedItemOwner: MockFactory {
    public static func makeMock() -> LGFeedItemOwner {
        return LGFeedItemOwner(
            id: String.makeRandom(),
            name: String.makeRandom(),
            avatarUrl: nil,
            geoData: nil)
    }
}
