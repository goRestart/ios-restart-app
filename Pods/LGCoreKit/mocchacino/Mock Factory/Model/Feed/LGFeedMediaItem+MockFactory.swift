extension LGFeedMediaItem: MockFactory {
    public static func makeMock() -> LGFeedMediaItem {
        return LGFeedMediaItem(image: LGFeedMediaOutput.makeMock(),
                               video: LGFeedMediaOutput.makeMock(),
                               videoThumb: LGFeedMediaOutput.makeMock())
    }
}

extension LGFeedMediaOutput: MockFactory {
    public static func makeMock() -> LGFeedMediaOutput {
        return LGFeedMediaOutput(id: String.makeRandom(), url: URL.makeRandom())
    }
}
