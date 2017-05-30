extension MockTransaction: MockFactory {
    public static func makeMock() -> MockTransaction {
        return MockTransaction(transactionId: String.makeRandom(), closed: Bool.makeRandom())
    }
}
