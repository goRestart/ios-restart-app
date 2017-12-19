extension MockSticker: MockFactory {
    public static func makeMock() -> MockSticker {
        return MockSticker(url: String.makeRandomURL(),
                           name: String.makeRandom(),
                           type: StickerType.makeMock())
    }
}
