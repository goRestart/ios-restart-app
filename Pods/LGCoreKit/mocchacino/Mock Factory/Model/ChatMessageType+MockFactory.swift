extension ChatMessageType: MockFactory {
    public static func makeMock() -> ChatMessageType {
        let allValues: [ChatMessageType] = [.text, .offer, .sticker, .quickAnswer, .expressChat, .favoritedListing, .phone, .chatNorris]
        return allValues.random()!
    }
}
