        
extension MockPassiveBuyersRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockPassiveBuyersRepository = self.init()
        mockPassiveBuyersRepository.showResult = PassiveBuyersResult(value: MockPassiveBuyersInfo.makeMock())
        mockPassiveBuyersRepository.contactResult = PassiveBuyersEmptyResult(value: Void())
        return mockPassiveBuyersRepository
    }
}
