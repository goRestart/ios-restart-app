extension ProductStatus: MockFactory {
    public static func makeMock() -> ProductStatus {
        let allValues: [ProductStatus] = [.pending, .approved, .discarded, .sold, .soldOld, .deleted]
        return allValues.random()!
    }
}
