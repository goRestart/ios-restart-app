extension StickerType: MockFactory {
    public static func makeMock() -> StickerType {
        let allValues: [StickerType] = [.product, .chat]
        return allValues.random()!
    }
}
