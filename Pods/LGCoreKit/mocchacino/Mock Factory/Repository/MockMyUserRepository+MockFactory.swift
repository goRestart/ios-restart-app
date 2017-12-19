
extension MockMyUserRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockMyUserRepository = self.init()
        mockMyUserRepository.result = MyUserResult(value: MockMyUser.makeMock())
        return mockMyUserRepository
    }
}
