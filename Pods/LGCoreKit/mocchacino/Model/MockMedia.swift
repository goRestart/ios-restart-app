public struct MockMedia: Media {
    public var objectId: String?
    public var type: MediaType
    public var snapshotId: String
    public var outputs: MediaOutputs
}

extension LGMedia: MockFactory {
    public static func makeMock() -> LGMedia {
        return LGMedia.init(objectId: String.makeRandom(),
                            type: MediaType.makeRandom(),
                            snapshotId: String.makeRandom(),
                            outputs: LGMediaOutputs.makeMock())
    }
}

extension MediaType: Randomizable {
    public static func makeRandom() -> MediaType {
        return MediaType.allValues[Int.makeRandom(min: 0, max: MediaType.allValues.count - 1)]
    }
}

extension LGMediaOutputs: MockFactory {
    public static func makeMock() -> LGMediaOutputs {
        return LGMediaOutputs.init(image: URL.makeRandom(),
                                   imageThumbnail: URL.makeRandom(),
                                   video: URL.makeRandom(),
                                   videoThumbnail: URL.makeRandom())
    }
}
