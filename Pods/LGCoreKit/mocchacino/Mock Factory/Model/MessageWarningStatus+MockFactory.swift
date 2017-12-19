extension MessageWarningStatus: MockFactory {
    public static func makeMock() -> MessageWarningStatus {
        let allValues: [MessageWarningStatus] = [.normal, .suspicious]
        return allValues.random()!
    }
}
