extension MockUserRating: MockFactory {
    public static func makeMock() -> MockUserRating {
        return MockUserRating(objectId: String.makeRandom(),
                              userToId: String.makeRandom(),
                              userFrom: MockUserProduct.makeMock(),
                              type: UserRatingType.makeMock(),
                              value: Int.makeRandom(),
                              comment: String?.makeRandom(),
                              status: UserRatingStatus.makeMock(),
                              createdAt: Date.makeRandom(),
                              updatedAt: Date.makeRandom())
    }
}
