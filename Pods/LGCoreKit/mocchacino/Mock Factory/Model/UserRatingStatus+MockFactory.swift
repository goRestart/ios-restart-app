extension UserRatingStatus: MockFactory {
    public static func makeMock() -> UserRatingStatus {
        let allValues: [UserRatingStatus] = [.published, .pendingReview, .deleted]
        return allValues.random()!
    }
}
