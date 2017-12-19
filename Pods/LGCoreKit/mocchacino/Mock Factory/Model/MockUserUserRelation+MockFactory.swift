extension MockUserUserRelation: MockFactory {
    public static func makeMock() -> MockUserUserRelation {
        return MockUserUserRelation(isBlocked: Bool.makeRandom(),
                                    isBlockedBy: Bool.makeRandom())
    }
}
