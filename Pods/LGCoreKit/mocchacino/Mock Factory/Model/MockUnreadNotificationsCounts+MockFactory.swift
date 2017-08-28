extension MockUnreadNotificationsCounts: MockFactory {
    public static func makeMock() -> MockUnreadNotificationsCounts {
        return MockUnreadNotificationsCounts(listingSold: Int.makeRandom(),
                                             listingLike: Int.makeRandom(),
                                             review: Int.makeRandom(),
                                             reviewUpdated: Int.makeRandom(),
                                             buyersInterested: Int.makeRandom(),
                                             listingSuggested: Int.makeRandom(),
                                             facebookFriendshipCreated: Int.makeRandom(),
                                             modular: Int.makeRandom(),
                                             total: Int.makeRandom())
    }
}
