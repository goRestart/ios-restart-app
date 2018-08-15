extension LGFeedMediaThumbnail: MockFactory {
    public static func makeMock() -> LGFeedMediaThumbnail {
        return LGFeedMediaThumbnail(
            type: .image,
            url: URL.makeRandom(),
            width: Float.makeRandom(),
            height: Float.makeRandom())
    }
}
