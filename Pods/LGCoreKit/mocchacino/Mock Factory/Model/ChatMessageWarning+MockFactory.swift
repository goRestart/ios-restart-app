extension ChatMessageWarning: MockFactory {
    public static func makeMock() -> ChatMessageWarning {
        let allValues: [ChatMessageWarning] = [.spam]
        return allValues.random()!
    }
}
