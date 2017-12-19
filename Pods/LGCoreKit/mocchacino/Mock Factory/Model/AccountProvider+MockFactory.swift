extension AccountProvider: MockFactory {
    public static func makeMock() -> AccountProvider {
        return AccountProvider.allValues.random()!
    }
}
