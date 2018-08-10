public struct MockMediaThumbnail: MediaThumbnail {
    public var file: File
    public var type: MediaType
    public var size: LGSize?
}

extension LGMediaThumbnail: MockFactory {
    public static func makeMock() -> LGMediaThumbnail {
        return LGMediaThumbnail.init(file: LGFile.makeMock(),
                                     type: MediaType.makeRandom(),
                                     size: LGSize.init(width: Float.makeRandom(), height: Float.makeRandom()))
    }
}

extension LGFile: MockFactory {
    public static func makeMock() -> LGFile {
        return LGFile.init(id: String.makeRandom(), url: URL.makeRandom())
    }
}
