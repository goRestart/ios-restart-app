
extension MockFileRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockFileRepository = self.init()
        mockFileRepository.uploadFileResult = FileResult(value: MockFile.makeMock())
        mockFileRepository.uploadFilesResult = FilesResult(value: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        return mockFileRepository
    }
}

