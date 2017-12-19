
extension MockUserRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockUserRepository = self.init()
        mockUserRepository.indexResult = UsersResult(value: MockUser.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockUserRepository.userResult = UserResult(value: MockUser.makeMock())
        mockUserRepository.userUserRelationResult = UserUserRelationResult(value: MockUserUserRelation.makeMock())
        mockUserRepository.emptyResult = UserVoidResult(value: Void())
        return mockUserRepository
    }
}
