import Result

open class MockFileRepository: FileRepository {
    public var uploadFileResult: FileResult
    public var uploadFilesResult: FilesResult


    // MARK: - Lifecycle

    public init() {
        self.uploadFileResult = FileResult(value: MockFile.makeMock())
        self.uploadFilesResult = FilesResult(value: MockFile.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }


    // MARK: - FileRepository

    public func upload(_ images: [UIImage], progress: ((Float) -> ())?, completion: FilesCompletion?) {
        delay(result: uploadFilesResult, completion: completion)
    }

    public func upload(_ image: UIImage, progress: ((Float) -> ())?, completion: FileCompletion?) {
        delay(result: uploadFileResult, completion: completion)
    }
}
