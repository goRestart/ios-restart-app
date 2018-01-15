extension UserType: MockFactory {
    public static func makeMock() -> UserType {
        return Bool.makeRandom() ? .user : .pro
    }
}
