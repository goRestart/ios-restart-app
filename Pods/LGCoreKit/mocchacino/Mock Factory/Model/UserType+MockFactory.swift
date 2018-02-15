extension UserType: MockFactory {
    public static func makeMock() -> UserType {
        let allValues: [UserType] = [.user, .pro, .dummy]
        return allValues.random()!
    }
}
