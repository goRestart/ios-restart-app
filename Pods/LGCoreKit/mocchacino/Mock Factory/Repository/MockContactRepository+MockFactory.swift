
extension MockContactRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockContactRepository = self.init()
        mockContactRepository.result = ContactResult(value: MockContact.makeMock())
        return mockContactRepository
    }
}


