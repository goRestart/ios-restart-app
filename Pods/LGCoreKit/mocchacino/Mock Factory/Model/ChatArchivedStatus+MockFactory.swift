extension ChatArchivedStatus: MockFactory {
    public static func makeMock() -> ChatArchivedStatus {
        let allValues: [ChatArchivedStatus] = [.active, .buyerArchived, .sellerArchived, .bothArchived]
        return allValues.random()!
    }
}
