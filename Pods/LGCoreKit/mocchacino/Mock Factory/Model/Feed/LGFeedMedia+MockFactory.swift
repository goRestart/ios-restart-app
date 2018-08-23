extension LGFeedMedia: MockFactory {
    public static func makeMock() -> LGFeedMedia {
        return LGFeedMedia(
            thumbnail: LGFeedMediaThumbnail.makeMock(),
            items: [LGFeedMediaItem.makeMock(), LGFeedMediaItem.makeMock()])
    }
}
