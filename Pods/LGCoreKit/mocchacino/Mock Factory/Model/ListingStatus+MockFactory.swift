extension ListingStatus: MockFactory {
    public static func makeMock() -> ListingStatus {
        let allValues: [ListingStatus] = [.pending, .approved, .discarded(reason: nil), .sold, .soldOld, .deleted]
        return allValues.random()!
    }
}
