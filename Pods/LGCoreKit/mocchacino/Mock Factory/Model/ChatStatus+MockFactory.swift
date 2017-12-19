extension ChatStatus: MockFactory {
    public static func makeMock() -> ChatStatus {
        let allValues: [ChatStatus] = [.available, .forbidden, .sold, .deleted]
        return allValues.random()!
    }
}
