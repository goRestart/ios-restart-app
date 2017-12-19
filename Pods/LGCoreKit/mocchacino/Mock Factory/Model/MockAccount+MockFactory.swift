extension MockAccount: MockFactory {
    public static func makeMock() -> MockAccount {
        return MockAccount(provider: AccountProvider.makeMock(),
                           verified: Bool.makeRandom())
    }
}
