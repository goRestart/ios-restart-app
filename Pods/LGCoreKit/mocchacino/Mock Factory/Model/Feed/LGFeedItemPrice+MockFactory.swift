extension LGFeedItemPrice: MockFactory {
    public static func makeMock() -> LGFeedItemPrice {
        return LGFeedItemPrice(
            amount: Double.makeRandom(),
            currency: String.makeRandom(),
            flag: .normal)
    }
}
