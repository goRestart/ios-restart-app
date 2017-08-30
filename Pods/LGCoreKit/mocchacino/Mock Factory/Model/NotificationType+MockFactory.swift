extension NotificationType: MockFactory {
    public static func makeMock() -> NotificationType {
        let listing = MockNotificationListing.makeMock()
        let user = MockNotificationUser.makeMock()

        switch Int.makeRandom(min: 0, max: 6) {
        case 0:
            return .like(listing: listing,
                         user: user)
        case 1:
            return .sold(listing: listing,
                         user: user)
        case 2:
            return .rating(user: user,
                           value: Int.makeRandom(),
                           comments: String?.makeRandom())
        case 3:
            return .ratingUpdated(user: user,
                                  value: Int.makeRandom(),
                                  comments: String?.makeRandom())
        case 4:
            return .buyersInterested(listing: listing,
                                     buyers: MockNotificationUser.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        case 5:
            return .listingSuggested(listing: listing,
                                     seller: user)
        default:
            return .facebookFriendshipCreated(user: user,
                                              facebookUsername: String.makeRandom())
        }
    }
}
