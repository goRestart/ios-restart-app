extension MockUserRating: MockFactory {
    public static func makeMock() -> MockUserRating {
        return MockUserRating(objectId: String.makeRandom(),
                              userToId: String.makeRandom(),
                              userFrom: MockUserListing.makeMock(),
                              listingId: String.makeRandom(),
                              type: UserRatingType.makeMock(),
                              value: Int.makeRandom(),
                              comment: String?.makeRandom(),
                              status: UserRatingStatus.makeMock(),
                              createdAt: Date.makeRandom(),
                              updatedAt: Date.makeRandom())
    }
}
