
extension MockStickersRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockStickersRepository = self.init()
        mockStickersRepository.showResult = StickersResult(value: MockSticker.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        return mockStickersRepository
    }
}



