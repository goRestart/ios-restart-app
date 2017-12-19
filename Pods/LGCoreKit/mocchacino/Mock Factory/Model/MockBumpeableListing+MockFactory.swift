extension MockBumpeableListing: MockFactory {
    public static func makeMock() -> MockBumpeableListing {
        return MockBumpeableListing(isBumpeable: Bool.makeRandom(),
                                    countdown: TimeInterval(Int.makeRandom()),
                                    maxCountdown: TimeInterval(Int.makeRandom()),
                                    totalBumps: Int.makeRandom(),
                                    bumpsLeft: Int.makeRandom(),
                                    timeSinceLastBump: TimeInterval(Int.makeRandom()),
                                    paymentItems: MockPaymentItem.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
