extension MockBumpeableProduct: MockFactory {
    public static func makeMock() -> MockBumpeableProduct {
        return MockBumpeableProduct(isBumpeable: Bool.makeRandom(),
                                    countdown: Int.makeRandom(),
                                    maxCountdown: Int.makeRandom(),
                                    totalBumps: Int.makeRandom(),
                                    bumpsLeft: Int.makeRandom(),
                                    timeSinceLastBump: Int.makeRandom(),
                                    paymentItems: MockPaymentItem.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
