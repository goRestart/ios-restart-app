extension ChatMessageType: MockFactory {
    public static func makeMock() -> ChatMessageType {
        let allValues: [ChatMessageType] = [.text, .offer, .sticker, .quickAnswer, .expressChat, .favoritedListing, .phone, .meeting]
        return allValues.random()!
    }
}
