extension Currency: MockFactory {
    public static func makeMock() -> Currency {
        return Currency(code: String.makeRandom(),
                        symbol: String.makeRandom())
    }
}
