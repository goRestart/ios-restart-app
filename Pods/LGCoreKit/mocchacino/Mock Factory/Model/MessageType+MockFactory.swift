extension MessageType: MockFactory {
    public static func makeMock() -> MessageType {
        let allValues: [MessageType] = [.text, .offer, .sticker]
        return allValues.random()!
    }
}
