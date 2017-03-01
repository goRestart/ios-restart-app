extension MockUnreadNotificationsCounts: MockFactory {
    public static func makeMock() -> MockUnreadNotificationsCounts {
        return MockUnreadNotificationsCounts(productSold: Int.makeRandom(),
                                             productLike: Int.makeRandom(),
                                             review: Int.makeRandom(),
                                             reviewUpdated: Int.makeRandom(),
                                             buyersInterested: Int.makeRandom(),
                                             productSuggested: Int.makeRandom(),
                                             facebookFriendshipCreated: Int.makeRandom(),
                                             total: Int.makeRandom())
    }
}
