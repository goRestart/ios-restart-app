extension UserStatus: MockFactory {
    public static func makeMock() -> UserStatus {
        return UserStatus.allValues.random()!
    }
}
