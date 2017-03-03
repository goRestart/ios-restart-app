extension MockPassiveBuyersInfo: MockFactory {
    public static func makeMock() -> MockPassiveBuyersInfo {
        return MockPassiveBuyersInfo(objectId: String.makeRandom(),
                                     productImage: MockFile?.makeMock(),
                                     passiveBuyers: MockPassiveBuyersUser.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
