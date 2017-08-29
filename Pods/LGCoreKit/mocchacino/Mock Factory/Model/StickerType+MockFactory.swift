extension StickerType: MockFactory {
    public static func makeMock() -> StickerType {
        let allValues: [StickerType] = [.listing, .chat]
        return allValues.random()!
    }
}
