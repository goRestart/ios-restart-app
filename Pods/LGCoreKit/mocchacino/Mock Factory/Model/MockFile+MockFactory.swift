extension MockFile: MockFactory {
    public static func makeMock() -> MockFile {
        return MockFile(objectId: String.makeRandom(),
                        fileURL: URL?.makeRandom())
    }
}
